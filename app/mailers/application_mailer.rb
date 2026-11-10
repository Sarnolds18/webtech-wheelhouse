class ApplicationMailer < ActionMailer::Base
  # The sender verified in the SMTP provider (Brevo). Development writes the same emails to tmp/mails.
  default from: "Wheelhouse <sarnolds@miuandes.cl>"
  layout "mailer"
end
