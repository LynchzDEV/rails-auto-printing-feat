require "test_helper"

class PrintControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should generate single PDF with default parameters" do
    get print_generate_pdf_path(format: :pdf)
    assert_response :success
    assert_equal "application/pdf", response.content_type
    assert_match /document_1_copies_\d{8}\.pdf/, response.headers['Content-Disposition']
  end

  test "should generate PDF with multiple copies" do
    get print_generate_pdf_path(format: :pdf), params: {
      customer_name: "Test Customer",
      copies: 3,
      include_summary: "1"
    }
    assert_response :success
    assert_equal "application/pdf", response.content_type
    assert_match /document_3_copies_\d{8}\.pdf/, response.headers['Content-Disposition']
  end

  test "should generate PDF with items" do
    get print_generate_pdf_path(format: :pdf), params: {
      customer_name: "Test Customer",
      copies: 2,
      items: [
        { name: "Widget", quantity: "2", price: "19.99", description: "Test widget" },
        { name: "Gadget", quantity: "1", price: "39.99" }
      ]
    }
    assert_response :success
    assert_equal "application/pdf", response.content_type
  end

  test "should generate separate PDFs as ZIP when print_mode is separate" do
    get print_generate_pdf_path(format: :pdf), params: {
      customer_name: "Test Customer",
      copies: 2,
      print_mode: "separate",
      items: [
        { name: "Test Item", quantity: "1", price: "10.00" }
      ]
    }
    assert_response :success
    assert_equal "application/zip", response.content_type
    assert_match /documents_2_copies_\d{8}\.zip/, response.headers['Content-Disposition']
  end

  test "should clamp copies to valid range" do
    get print_generate_pdf_path(format: :pdf), params: {
      copies: 100  # Should be clamped to 50
    }
    assert_response :success
    assert_equal "application/pdf", response.content_type
  end

  test "should handle missing items gracefully" do
    get print_generate_pdf_path(format: :pdf), params: {
      customer_name: "Test Customer",
      copies: 1
    }
    assert_response :success
    assert_equal "application/pdf", response.content_type
  end
end
