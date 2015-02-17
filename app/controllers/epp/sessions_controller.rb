class Epp::SessionsController < EppController
  def hello
    render_epp_response('greeting')
  end

  def login
    # pki login
    if request.env['HTTP_SSL_CLIENT_S_DN_CN'] == login_params[:username]
      @api_user = ApiUser.find_by(username: login_params[:username])
    else
      @api_user = ApiUser.find_by(login_params)
    end

    if @api_user.try(:active)
      epp_session[:api_user_id] = @api_user.id
      render_epp_response('login_success')
    else
      response.headers['X-EPP-Returncode'] = '2200'
      render_epp_response('login_fail')
    end
  end

  def logout
    @api_user = current_user # cache current_user for logging
    epp_session[:api_user_id] = nil
    response.headers['X-EPP-Returncode'] = '1500'
    render_epp_response('logout')
  end

  ### HELPER METHODS ###

  def login_params
    ph = params_hash['epp']['command']['login']
    { username: ph[:clID], password: ph[:pw] }
  end
end
