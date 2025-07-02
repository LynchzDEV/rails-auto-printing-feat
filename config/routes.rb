Rails.application.routes.draw do
  root "print#index"
  get "print/generate_pdf", to: "print#generate_pdf"
end
