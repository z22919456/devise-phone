class Devise::PhoneConfirmationsController < DeviseController
  # GET /resource/phone_confirmation/new
  def new
    self.resource = resource_class.new
  end

  # POST /resource/phone_confirmation
  def create
    self.resource = resource_class.send_phone_confirmation_otp(resource_params[:phone])
    yield resource if block_given?

    if resource.errors.empty?
      redirect_to action: :edit, id: resource.id
    else
      respond_with(resource)
    end
  end

  # GET /resource/phone_confirmation/edit
  def edit
    self.resource = resource_class.find(params[:id])

    redirect_to phone_confirmation_path and return if resource.blank?
  end

  # POST /resource/phone_confirmation
  def update
    self.resource = resource_class.mobile_confirm_by_otp(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message!(:notice, :mobile_confirmed)
      respond_with_navigational(resource) { redirect_to phone_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end

  protected

  # The path used after resending confirmation instructions.
  def phone_confirmation_instructions_path_for(resource_name)
    is_navigational_format? ? new_session_path(resource_name) : '/'
  end

  # The path used after confirmation.
  def after_resending_confirmation_path_for(resource_name, resource)
    if signed_in?(resource_name)
      signed_in_root_path(resource)
    else
      new_session_path(resource_name)
    end
  end

  def translation_scope
    'devise.phone_confirmations'
  end
end
