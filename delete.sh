#!/bin/bash
#
# notice_foreign 서비스 제거 (nginx 가상호스트 + systemd)
# 사용법: ./delete.sh  (앱 루트에서 실행)
# 앱 소스/DB(storage 등)는 삭제하지 않습니다.
#

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_step()    { echo -e "${MAGENTA}[STEP]${NC} $1"; }

DOMAIN="${DOMAIN:-daeum.gbeai.net}"
APP_NAME="${APP_NAME:-notice_foreign}"
NGINX_AVAILABLE="/etc/nginx/sites-available/${DOMAIN}"
NGINX_ENABLED="/etc/nginx/sites-enabled/${DOMAIN}"
SYSTEMD_SERVICE="/etc/systemd/system/${APP_NAME}.service"

echo ""
log_step "===================================================="
log_step "notice_foreign 서비스 제거"
log_step "===================================================="
echo ""
log_info "도메인=${DOMAIN}, 앱=${APP_NAME}"
echo ""

# systemd 서비스 제거
if [ -f "$SYSTEMD_SERVICE" ]; then
    log_step "systemd 서비스 중지 및 비활성화..."
    sudo systemctl stop "$APP_NAME"    2>/dev/null || true
    sudo systemctl disable "$APP_NAME"  2>/dev/null || true
    sudo rm -f "$SYSTEMD_SERVICE"
    sudo systemctl daemon-reload
    log_success "systemd 서비스 제거 완료"
else
    log_info "systemd 서비스 파일이 없습니다. 건너뜀."
fi

# nginx 사이트 제거
if [ -L "$NGINX_ENABLED" ] || [ -f "$NGINX_ENABLED" ]; then
    log_step "nginx 사이트 비활성화..."
    sudo rm -f "$NGINX_ENABLED"
fi
if [ -f "$NGINX_AVAILABLE" ]; then
    log_step "nginx 사이트 설정 파일 삭제..."
    sudo rm -f "$NGINX_AVAILABLE"
fi
if command -v nginx &>/dev/null; then
    if sudo nginx -t 2>/dev/null; then
        sudo systemctl reload nginx
        log_success "nginx 재로드 완료"
    fi
fi

echo ""
log_success "서비스 제거 완료."
echo ""
echo -e "${BLUE}참고:${NC}"
echo -e "   - 인증서 삭제: ${YELLOW}sudo certbot delete --cert-name ${DOMAIN}${NC}"
echo -e "   - 앱 디렉터리/DB는 그대로 두었습니다. 수동 삭제 시 현재 디렉터리를 삭제하면 됩니다."
echo ""
