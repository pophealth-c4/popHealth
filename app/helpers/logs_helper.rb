module LogsHelper
  def time_range_params_plus(url_params_hash)
    url_params_hash[:log_start_date] = params[:log_start_date] if params[:log_start_date]
    url_params_hash[:log_end_date] = params[:log_end_date] if params[:log_end_date]
    url_params_hash
  end

  def log_controller_call(details, is_sensitive = false)
    log_call details, true, false, false, is_sensitive
  end

  def log_api_call(details, is_sensitive = false)
    log_call "API - " + details, true, false, true, is_sensitive
  end

  def log_admin_api_call(details, is_sensitive = false)
    log_call "Admin API - " + details, true, true, true, is_sensitive
  end

  def log_admin_controller_call(details, is_sensitive = false)
    log_call "Admin - " + details, true, true, false, is_sensitive
  end

  def log_call(details, controller, admin, api, is_sensitive)
    log_config = APP_CONFIG['log_to_database']
    return if log_config.nil?
    return unless
      (log_config["controller"] and controller) or
      (log_config["admin"] and admin) or
      (log_config["api"] and api) or
      (log_config["is_sensitive"] and is_sensitive)

    user = current_user || @current_user
    Log.create(:username => user.username,
      :event => details + (params.nil? ? '' : " Parameters: #{params.except(:action, :controller, :utf8, :authenticity_token).inspect}"),
      :medical_record_number => (@patient.nil? ? nil : @patient.medical_record_number))
  end

  def get_errors_for_log(item)
    if item.nil? or item.errors.nil? or item.errors.empty?
      "(none)"
    else
      item.errors.messages
    end
  end
end
