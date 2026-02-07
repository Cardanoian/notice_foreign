require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get docs_index_url
    assert_response :success
  end

  test "should get show" do
    get docs_show_url
    assert_response :success
  end
end
