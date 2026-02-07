#!/bin/bash
#
# notice_foreign 배포 스크립트 (nginx 443 + Let's Encrypt DNS + Rails Puma)
# 사용법: ./deploy.sh  (서버 앱 루트에서 실행, nginx/systemd 작업 시 sudo 사용)
#
# 최초: nginx·certbot, 인증서(DNS 수동), nginx 가상호스트, systemd 등록
# 재실행: bundle, db:migrate, assets, 서비스 재시작
#

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# 로그 함수
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
log_step()    { echo -e "${MAGENTA}[STEP]${NC} $1"; }

# 설정 (필요 시 수정)
DOMAIN="${DOMAIN:-daeum.gbeai.net}"
APP_NAME="${APP_NAME:-notice_foreign}"
PUMA_PORT="${PUMA_PORT:-3000}"
NGINX_AVAILABLE="/etc/nginx/sites-available/${DOMAIN}"
NGINX_ENABLED="/etc/nginx/sites-enabled/${DOMAIN}"
SYSTEMD_SERVICE="/etc/systemd/system/${APP_NAME}.service"
LETSENCRYPT_LIVE="/etc/letsencrypt/live/${DOMAIN}"

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$APP_DIR"

print_banner() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║                                                       ║"
    echo "║         notice_foreign 배포 스크립트                   ║"
    echo "║                                                       ║"
    echo "║     https://${DOMAIN}                          ║"
    echo "║     (nginx 443 + Let's Encrypt DNS + Puma)            ║"
    echo "║                                                       ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_rails_master_key() {
    set -a
    [ -f .env ] && source .env
    [ -f .env.production ] && source .env.production
    set +a
    if [ -z "${RAILS_MASTER_KEY}" ]; then
        log_error "RAILS_MASTER_KEY가 필요합니다. config/master.key 내용을 .env 또는 .env.production 에 RAILS_MASTER_KEY=... 로 넣거나 export 해주세요."
    fi
    log_success "RAILS_MASTER_KEY 확인 완료"
}

export RAILS_ENV=production
export SOLID_QUEUE_IN_PUMA=1

setup_server() {
    log_step "===================================================="
    log_step "서버 설정 (nginx + SSL + systemd)"
    log_step "===================================================="

    log_step "nginx, certbot 설치 확인..."
    if ! command -v nginx &>/dev/null; then
        sudo apt-get update -qq
        sudo apt-get install -y nginx certbot
    fi
    log_success "nginx/certbot 준비 완료"

    log_step "Let's Encrypt 인증서 (DNS 검증, 80 포트 불필요)..."
    if [ ! -d "$LETSENCRYPT_LIVE" ]; then
        log_info "아래 안내에 따라 DNS에 TXT 레코드를 추가한 뒤 Enter를 누르세요."
        sudo certbot certonly --manual --preferred-challenges dns -d "$DOMAIN"
    else
        log_success "인증서가 이미 있습니다: $LETSENCRYPT_LIVE"
    fi

    log_step "nginx 사이트 설정 (443만 사용)..."
    sudo tee "$NGINX_AVAILABLE" >/dev/null <<NGINX
server {
    listen 443 ssl;
    server_name ${DOMAIN};

    ssl_certificate     ${LETSENCRYPT_LIVE}/fullchain.pem;
    ssl_certificate_key ${LETSENCRYPT_LIVE}/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:${PUMA_PORT};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
NGINX
    sudo ln -sf "$NGINX_AVAILABLE" "$NGINX_ENABLED"
    sudo nginx -t && sudo systemctl reload nginx
    log_success "nginx 설정 완료"

    log_step "systemd 서비스 등록..."
    sudo tee "$SYSTEMD_SERVICE" >/dev/null <<SYSTEMD
[Unit]
Description=${APP_NAME} (Puma)
After=network.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=${APP_DIR}
Environment=RAILS_ENV=production
Environment=RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
Environment=SOLID_QUEUE_IN_PUMA=1
ExecStart=$(which bundle) exec puma -b tcp://127.0.0.1:${PUMA_PORT} -C config/puma.rb
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SYSTEMD
    sudo systemctl daemon-reload
    sudo systemctl enable "$APP_NAME"
    log_success "systemd 서비스 등록 완료"
}

prepare_app() {
    log_step "Rails 앱 준비 (bundle, db, assets)..."
    bundle install --without development test
    bundle exec rails db:prepare
    bundle exec rails assets:precompile
    log_success "앱 준비 완료"
}

deploy_app() {
    log_step "배포: bundle, db:migrate, assets, 서비스 재시작..."
    bundle install --without development test
    bundle exec rails db:migrate
    bundle exec rails assets:precompile
    sudo systemctl restart "$APP_NAME"
    sudo systemctl status "$APP_NAME" --no-pager || true
    log_success "배포 완료"
}

print_deployment_info() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              🎉 notice_foreign 배포 완료! 🎉          ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📍 접속 정보:${NC}"
    echo -e "   - 앱: ${GREEN}https://${DOMAIN}${NC}"
    echo ""
    echo -e "${BLUE}🔧 유용한 명령어:${NC}"
    echo -e "   - 서비스 상태: ${YELLOW}systemctl status ${APP_NAME}${NC}"
    echo -e "   - 서비스 로그: ${YELLOW}journalctl -u ${APP_NAME} -f${NC}"
    echo -e "   - nginx 상태: ${YELLOW}systemctl status nginx${NC}"
    echo -e "   - SSL 인증서: ${YELLOW}certbot certificates${NC}"
    echo ""
    echo -e "${BLUE}🗑️  서비스 제거:${NC}"
    echo -e "   - ${YELLOW}./delete.sh${NC}"
    echo ""
}

# ---------- 메인 ----------
main() {
    print_banner
    log_info "배포를 시작합니다..."
    echo ""

    check_rails_master_key

    if [ -f "$SYSTEMD_SERVICE" ]; then
        log_info "기존 서비스가 있습니다. 배포(업데이트) 모드로 진행합니다."
        prepare_app
        deploy_app
    else
        log_info "최초 설정 모드로 진행합니다."
        setup_server
        prepare_app
        sudo systemctl start "$APP_NAME"
        sudo systemctl status "$APP_NAME" --no-pager || true
        log_success "최초 배포 완료"
    fi

    print_deployment_info
    log_success "모든 배포 과정이 완료되었습니다! 🚀"
}

main
