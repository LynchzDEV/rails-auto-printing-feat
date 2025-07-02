# Demo Print - Multi-Page PDF Generator

A Rails 8 application that demonstrates dynamic multi-page PDF generation with customer information, itemized details, and customizable printing options.

## 🚀 Features

- **Dynamic PDF Generation**: Create multi-page PDFs with customer data and item details
- **Flexible Copy Options**: Generate 1-200 copies with multiple print modes
- **Print Modes**: Single PDF with all copies OR separate PDF files (as ZIP)
- **Item Detail Pages**: Each item gets its own detailed page with descriptions
- **Summary Reports**: Optional summary pages with totals and statistics
- **Responsive Web Interface**: Clean, modern form interface for data input
- **Auto-Print Support**: Generate and automatically trigger print dialog
- **Dockerized Deployment**: Ready for containerized deployment with Kamal

## 📋 Requirements

- **Ruby**: 3.3.6
- **Rails**: 8.0.2
- **Database**: PostgreSQL
- **Node.js**: For asset compilation (if needed)
- **Docker**: For containerized deployment (optional)

## 🛠️ Installation & Setup

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd demo-print
   ```

2. **Install Ruby dependencies**
   ```bash
   bundle install
   ```

3. **Setup environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

4. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   ```

5. **Start the development server**
   ```bash
   rails server
   ```

6. **Visit the application**
   Navigate to `http://localhost:3000`

### Docker Development

1. **Start with Docker Compose**
   ```bash
   # Set environment variables
   export DB_USERNAME=postgres
   export DB_PASSWORD=password
   export DB_NAME=demo_print_development

   # Start PostgreSQL
   docker-compose up -d db

   # Build and run the app
   docker build -t demo-print .
   docker run -p 3000:80 demo-print
   ```

## 🏗️ Project Structure

```
demo-print/
├── app/
│   ├── controllers/
│   │   └── print_controller.rb    # Main PDF generation logic
│   └── views/
│       └── print/
│           └── index.html.erb     # Web form interface
├── config/
│   └── routes.rb                  # Application routes
├── Dockerfile                     # Production container setup
├── docker-compose.yml            # Development database setup
└── Gemfile                       # Ruby dependencies
```

## 📖 Usage

### Web Interface

1. **Access the Form**: Visit the root URL (`/`) to access the PDF generation form
2. **Enter Customer Info**: Fill in customer name and details
3. **Add Items**: Use the dynamic form to add multiple items with:
   - Item name
   - Quantity
   - Price
   - Optional description
4. **Configure Options**:
   - Number of copies (1-200)
   - Print mode (single PDF or separate PDFs)
   - Include summary page (checkbox)
5. **Generate PDF**: Click "Generate PDF" or "Generate & Auto-Print"

### PDF Structure

Generated PDFs contain:

1. **Main Page** (per copy):
   - Customer information
   - Items overview table
   - Grand total
   - Copy information and print mode

2. **Item Detail Pages** (per item, per copy):
   - Detailed item information
   - Formatted layout with item specifics
   - Item codes and metadata

3. **Summary Page** (optional, per copy):
   - Total statistics
   - Value distribution
   - Report metadata

### Print Modes

- **Single PDF Mode**: All copies are included in one PDF file (default)
- **Separate PDF Mode**: Each copy is generated as a separate PDF file, delivered as a ZIP archive

### API Endpoints

- `GET /` - Main form interface
- `GET /print/generate_pdf` - PDF generation endpoint
  - Parameters:
    - `customer_name`: Customer name
    - `items[][name]`: Item names
    - `items[][quantity]`: Item quantities
    - `items[][price]`: Item prices
    - `items[][description]`: Item descriptions
    - `copies`: Number of copies (1-200)
    - `print_mode`: Print mode ('single' or 'separate')
    - `include_summary`: Include summary page (0/1)

## 🧰 Key Dependencies

### Core Framework
- **Rails 8.0.2**: Web framework
- **Puma**: Web server
- **PostgreSQL**: Database

### PDF Generation
- **Prawn**: PDF generation library
- **Prawn-table**: Table formatting for PDFs
- **RubyZip**: ZIP file creation for separate PDF mode

### Frontend
- **Turbo Rails**: SPA-like experience
- **Stimulus**: JavaScript framework
- **Importmap**: JavaScript module management

### Development & Testing
- **Debug**: Debugging tools
- **Brakeman**: Security scanning
- **RuboCop**: Code linting
- **Capybara & Selenium**: System testing

### Deployment
- **Kamal**: Deployment tool
- **Thruster**: HTTP/2 proxy
- **Solid Cache/Queue/Cable**: Rails 8 solid libraries

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
rails test

# Run system tests
rails test:system

# Run specific test files
rails test test/controllers/print_controller_test.rb
```

## 🚀 Deployment

### Production with Kamal

1. **Setup Kamal configuration**
   ```bash
   # Edit config/deploy.yml with your settings
   kamal setup
   ```

2. **Deploy**
   ```bash
   kamal deploy
   ```

### Manual Docker Deployment

1. **Build production image**
   ```bash
   docker build -t demo-print .
   ```

2. **Run container**
   ```bash
   docker run -d \
     -p 80:80 \
     -e RAILS_MASTER_KEY=<your-master-key> \
     --name demo-print \
     demo-print
   ```

## 🔧 Configuration

### Environment Variables

Create a `.env` file for local development:

```env
DB_USERNAME=postgres
DB_PASSWORD=password
DB_NAME=demo_print_development
RAILS_MASTER_KEY=<your-master-key>
```

### Database Configuration

The application uses PostgreSQL. Configure database settings in:
- `config/database.yml`
- Environment variables (preferred for production)

## 📝 Development Notes

### Code Quality

The project includes several code quality tools:

```bash
# Run RuboCop for style checking
bundle exec rubocop

# Run Brakeman for security scanning
bundle exec brakeman

# Format code
bundle exec rubocop -A
```

### PDF Customization

To customize PDF generation:

1. **Modify `print_controller.rb`**: Update the PDF generation methods
2. **Styling**: Adjust fonts, colors, and layouts in the PDF generation methods
3. **Content**: Modify the data structure and content organization

### Adding Features

To extend functionality:

1. **New PDF sections**: Add methods to `PrintController`
2. **Form fields**: Update `index.html.erb` and controller params
3. **Styling**: Modify the embedded CSS in the view template
4. **Print modes**: Extend the `generate_separate_pdfs` method for new output formats

### Print Feature Details

The enhanced printing system supports:

- **Flexible copy counts**: 1-200 copies with input validation
- **Multiple output modes**: Single PDF or ZIP of separate PDFs
- **Performance optimization**: Separate PDF generation for large copy counts
- **User warnings**: Alerts for large separate PDF generations

## 🐛 Troubleshooting

### Common Issues

1. **PDF Generation Fails**
   - Check Prawn gem installation
   - Verify all required parameters are present
   - Check server logs for detailed errors

2. **Database Connection Issues**
   - Verify PostgreSQL is running
   - Check database credentials in `.env`
   - Ensure database exists and is accessible

3. **Asset Issues**
   - Run `rails assets:precompile` for production
   - Check importmap configuration

### Debugging

Enable detailed logging in development:

```ruby
# In config/environments/development.rb
config.log_level = :debug
```

## 📄 License

This project is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For questions or issues:

1. Check the [Issues](../../issues) page
2. Create a new issue with detailed information
3. Include relevant logs and error messages

---

**Demo Print** - Showcasing dynamic PDF generation with Rails 8 and Prawn
