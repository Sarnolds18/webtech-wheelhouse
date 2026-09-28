module ApplicationHelper
  # The CSS class for one form field, with Bootstrap's invalid state added when the field's
  # attribute has errors. Pass "form-select" or "form-check-input" as the base for those fields.
  def field_class(form, attribute, base = "form-control")
    field_error_messages(form, attribute).any? ? "#{base} is-invalid" : base
  end

  # The messages for one field, drawn under it. Renders nothing for a field without errors.
  def field_errors(form, attribute)
    messages = field_error_messages(form, attribute)
    return if messages.empty?

    tag.div(safe_join(messages, tag.br), class: "invalid-feedback")
  end

  private

  # A belongs_to reports its error on the association (:bike), while its select sends the
  # column (:bike_id), so a field ending in _id collects both.
  def field_error_messages(form, attribute)
    errors = form.object.errors
    attributes = [ attribute, attribute.to_s.delete_suffix("_id").to_sym ].uniq
    attributes.flat_map { |name| errors.full_messages_for(name) }
  end
end
