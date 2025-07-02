class PrintController < ApplicationController
  def index
  end

  def generate_pdf
    @customer_name = params[:customer_name] || "Default Customer"
    @items = parse_items_from_params
    @copies = params[:copies]&.to_i || 1
    @include_summary = params[:include_summary] == "1"

    respond_to do |format|
      format.pdf do
        pdf_content = generate_multi_page_pdf

        send_data pdf_content,
                  filename: "multi_page_document_#{Date.current.strftime('%Y%m%d')}.pdf",
                  type: "application/pdf",
                  disposition: "inline"
      end
    end
  end

  private

  def parse_items_from_params
    items = []
    return items unless params[:items].present?

    params[:items].each do |item_data|
      next unless item_data[:name].present?

      items << {
        name: item_data[:name],
        quantity: item_data[:quantity]&.to_i || 1,
        price: item_data[:price]&.to_f || 0.0,
        description: item_data[:description] || ""
      }
    end

    items
  end

  def generate_multi_page_pdf
    require 'prawn'

    Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
      pdf.font "Helvetica"

      @copies.times do |copy_number|
        pdf.start_new_page unless copy_number == 0

        generate_main_page(pdf, copy_number + 1)

        @items.each_with_index do |item, index|
          pdf.start_new_page
          generate_item_detail_page(pdf, item, index + 1, copy_number + 1)
        end

        if @include_summary
          pdf.start_new_page
          generate_summary_page(pdf, copy_number + 1)
        end
      end

      add_page_numbers(pdf)

    end.render
  end

  def generate_main_page(pdf, copy_number)
    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
      pdf.text "DOCUMENT COPY ##{copy_number}",
               size: 20, style: :bold, align: :center, color: "0066CC"
      pdf.move_down 10

      pdf.stroke_horizontal_rule
      pdf.move_down 20
    end

    pdf.text "Customer Information", size: 16, style: :bold, color: "333333"
    pdf.move_down 10

    customer_info = [
      ["Customer Name:", @customer_name],
      ["Document Date:", Date.current.strftime('%B %d, %Y')],
      ["Generated At:", Time.current.strftime('%I:%M %p')],
      ["Total Items:", @items.length.to_s]
    ]

    pdf.table(customer_info, cell_style: { borders: [] }) do
      column(0).font_style = :bold
      column(0).width = 120
      cells.padding = [2, 8]
    end

    pdf.move_down 30

    if @items.any?
      pdf.text "Items Overview", size: 16, style: :bold, color: "333333"
      pdf.move_down 10

      table_data = [["#", "Item Name", "Quantity", "Price", "Total"]]

      @items.each_with_index do |item, index|
        total = item[:quantity] * item[:price]
        table_data << [
          (index + 1).to_s,
          item[:name],
          item[:quantity].to_s,
          "$#{sprintf('%.2f', item[:price])}",
          "$#{sprintf('%.2f', total)}"
        ]
      end

      grand_total = @items.sum { |item| item[:quantity] * item[:price] }
      table_data << ["", "", "", "Grand Total:", "$#{sprintf('%.2f', grand_total)}"]

      pdf.table(table_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "E6F3FF"
        row(-1).font_style = :bold
        row(-1).background_color = "F0F0F0"
        cells.padding = 8
        cells.border_width = 1
        cells.border_color = "CCCCCC"
      end
    else
      pdf.text "No items specified", style: :italic, color: "666666"
    end

    pdf.move_down 30

    pdf.bounding_box([0, 100], width: pdf.bounds.width) do
      pdf.stroke_horizontal_rule
      pdf.move_down 10
      pdf.text "This is page 1 of copy #{copy_number}. Detailed item information follows on subsequent pages.",
               size: 10, color: "666666", align: :center
    end
  end

  def generate_item_detail_page(pdf, item, item_number, copy_number)
    pdf.text "ITEM DETAIL ##{item_number} - COPY #{copy_number}",
             size: 18, style: :bold, align: :center, color: "006600"
    pdf.move_down 5
    pdf.stroke_horizontal_rule
    pdf.move_down 20

    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width, height: 200) do
      pdf.stroke_bounds
      pdf.fill_color "F8F8F8"
      pdf.fill_rectangle([0, 200], pdf.bounds.width, 200)
      pdf.fill_color "000000"

      pdf.move_down 20
      pdf.indent(20) do
        pdf.text item[:name], size: 20, style: :bold, color: "006600"
        pdf.move_down 15

        details = [
          ["Quantity:", item[:quantity].to_s],
          ["Unit Price:", "$#{sprintf('%.2f', item[:price])}"],
          ["Total Value:", "$#{sprintf('%.2f', item[:quantity] * item[:price])}"],
          ["Description:", item[:description].present? ? item[:description] : "No description provided"]
        ]

        details.each do |label, value|
          pdf.text "#{label} #{value}", size: 12
          pdf.move_down 8
        end
      end
    end

    pdf.move_down 30

    pdf.text "Additional Information", size: 14, style: :bold
    pdf.move_down 10

    pdf.text "• Item processed on: #{Time.current.strftime('%B %d, %Y at %I:%M %p')}", size: 11
    pdf.text "• Copy reference: #{copy_number}", size: 11
    pdf.text "• Item sequence: #{item_number} of #{@items.length}", size: 11

    pdf.move_down 20
    pdf.text "Item Code: ITEM-#{item_number.to_s.rjust(3, '0')}-#{copy_number}",
             size: 10, font: "Courier"
  end

  def generate_summary_page(pdf, copy_number)
    pdf.text "SUMMARY REPORT - COPY #{copy_number}",
             size: 18, style: :bold, align: :center, color: "CC6600"
    pdf.move_down 5
    pdf.stroke_horizontal_rule
    pdf.move_down 20

    total_quantity = @items.sum { |item| item[:quantity] }
    total_value = @items.sum { |item| item[:quantity] * item[:price] }
    avg_price = @items.any? ? (@items.sum { |item| item[:price] } / @items.length) : 0

    summary_data = [
      ["Total Items:", @items.length.to_s],
      ["Total Quantity:", total_quantity.to_s],
      ["Total Value:", "$#{sprintf('%.2f', total_value)}"],
      ["Average Price:", "$#{sprintf('%.2f', avg_price)}"],
      ["Document Copy:", copy_number.to_s],
      ["Generated:", Time.current.strftime('%B %d, %Y at %I:%M %p')]
    ]

    pdf.table(summary_data, position: :center, cell_style: { size: 12 }) do
      column(0).font_style = :bold
      column(0).width = 150
      cells.padding = 10
      cells.border_width = 1
      cells.border_color = "CCCCCC"
    end

    pdf.move_down 30

    pdf.text "Value Distribution:", size: 14, style: :bold
    pdf.move_down 10

    @items.each do |item|
      item_total = item[:quantity] * item[:price]
      percentage = total_value > 0 ? (item_total / total_value * 100).round(1) : 0

      pdf.text "#{item[:name]}: #{percentage}% ($#{sprintf('%.2f', item_total)})", size: 11
      pdf.move_down 5
    end
  end

  def add_page_numbers(pdf)
    pdf.number_pages "Page <page> of <total>",
                     at: [pdf.bounds.right - 100, 0],
                     width: 100,
                     align: :right,
                     size: 10
  end
end
