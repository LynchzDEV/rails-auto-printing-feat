Rails.application.routes.draw do
  root "print#index"
  get "print/generate_pdf", to: "print#generate_pdf"

  # Certificate Generator
  get "certificate", to: "certificate#index"
  post "certificate/generate", to: "certificate#generate"
end
