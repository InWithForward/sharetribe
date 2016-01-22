module Trello

  BASE_URL = 'https://api.trello.com'

  CREDENTIALS = {
    key: APP_CONFIG.trello_api_key,
    token: APP_CONFIG.trello_api_token
  }

  BOARD_ID = APP_CONFIG.trello_board_id

  module_function

  def post(path, params = {})
    versioned_path = '/1' + path

    response = Faraday.
      new(BASE_URL, params: CREDENTIALS).
      post(versioned_path, params)

    JSON.parse(response.body)
  end
end

