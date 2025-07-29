require "prawn"
require "prawn/table"
require "openssl"
require "base64"

class CertificateController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:generate]

  def index
  end

  def generate
    @recipient_name = params[:recipient_name]

    # Generate cryptographic signature
    signature = generate_crypto_signature(@recipient_name)

    # Generate PDF
    pdf_content = generate_certificate_pdf(@recipient_name, signature)

    send_data pdf_content,
              filename: "Certificate_#{@recipient_name.gsub(/\s+/, '')}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def generate_certificate_pdf(recipient_name, signature)
    Prawn::Document.new(page_size: "A4", page_layout: :landscape) do |pdf|
      pdf.font "Helvetica"

      # Background
      pdf.canvas do
        pdf.fill_color "F0F8FF"
        pdf.fill_rectangle [0, pdf.bounds.top], pdf.bounds.width, pdf.bounds.height
      end

      # Border
      pdf.stroke_color "00008B"
      pdf.stroke_bounds

      # Content
      pdf.move_down 100
      pdf.text "Certificate of Achievement", size: 40, align: :center, style: :bold, color: "00008B"

      pdf.move_down 30
      pdf.text "This certificate is proudly presented to", size: 18, align: :center

      pdf.move_down 40
      pdf.text recipient_name, size: 32, align: :center, style: :bold_italic, color: "006400"

      pdf.move_down 40
      pdf.text "For successfully completing the course on an introduction to programming.", size: 16, align: :center

      pdf.move_down 60

      # Add the signature from the canvas
      if params[:signature_data].present?
        Rails.logger.debug "Raw signature_data: #{params[:signature_data][0..100]}... (truncated)"
        signature_data = params[:signature_data].split(',').last
        decoded_data = Base64.decode64(signature_data)
        Rails.logger.debug "Decoded signature_data length: #{decoded_data.length}"
        # Position the image at a fixed Y coordinate (e.g., 180 from the bottom)
        pdf.image StringIO.new(decoded_data), at: [pdf.bounds.width / 2 - 75, 180], width: 150
      else
        Rails.logger.debug "No signature_data present in params."
      end

      pdf.stroke_horizontal_rule
      pdf.move_down 10
      pdf.text "Authorized Signature", size: 12, align: :center

      # Add cryptographic signature as a QR code
      pdf.bounding_box([pdf.bounds.width - 150, 120], width: 120) do
        pdf.text "Digital Signature:", size: 10, align: :center
        pdf.text signature, size: 8, align: :center, font: "Courier"
      end
    end.render
  end

  def generate_crypto_signature(data)
    private_key_path = Rails.root.join("config", "private_key.pem")
    unless File.exist?(private_key_path)
      generate_keys
    end
    private_key = OpenSSL::PKey::RSA.new(File.read(private_key_path))
    signature = private_key.sign(OpenSSL::Digest::SHA256.new, data)
    Base64.strict_encode64(signature)
  end

  def generate_keys
    key = OpenSSL::PKey::RSA.new(2048)
    private_key = key.to_pem
    public_key = key.public_key.to_pem

    File.write(Rails.root.join("config", "private_key.pem"), private_key)
    File.write(Rails.root.join("config", "public_key.pem"), public_key)
  end
end
