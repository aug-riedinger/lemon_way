# require 'active_support/core_ext/hash'
# require 'active_support/builder'
require 'net/http'
require 'uri'

module LemonWay
  class Client
    attr_reader :uri, :auth, :options

    @@api_method_calls = %w(
      FastPay
      GetBalances
      GetKycStatus
      GetMoneyInIBANDetails
      GetMoneyInTransDetails
      GetMoneyOutTransDetails
      GetPaymentDetails
      GetWalletDetails
      MoneyIn
      MoneyIn3DConfirm
      MoneyIn3DInit
      MoneyInWebInit
      MoneyInWithCardId
      MoneyOut
      RefundMoneyIn
      RegisterCard
      RegisterIBAN
      RegisterWallet
      SendPayment
      UnregisterCard
      UpdateWalletDetails
      UpdateWalletStatus
      UploadFile
    )

    @@api_method_calls.each do |action|
      define_method(action.underscore.to_sym) do |version, params, &block|
        uri = URI.parse("#{@uri}/#{action}")
        params = prefix_email_and_wallet_id(@auth.merge({version: version}).merge(params))
        self.class.send_request(uri, params, {debug: @debug}, &block)
      end
    end

    def initialize(opts = {})
      @uri = URI.parse(opts.delete(:uri))

      @auth = {
        wlLogin: opts.delete(:wlLogin),
        wlPass: opts.delete(:wlPass),
        language: opts.delete(:language),
        walletIp: opts.delete(:walletIp) || '', 
        walletUa:  opts.delete(:walletUa) || ''
      }

      @debug = opts.delete(:debug)
      @prefix = opts.delete(:prefix)
    end

    def prefix_email_and_wallet_id(params)
      if @prefix
        params[:clientMail] = "#{@prefix}-#{params[:clientMail]}"
        params[:wallet] = "#{@prefix}-#{params[:wallet]}"
        params[:debitWallet] = "#{@prefix}-#{params[:debitWallet]}"
        params[:creditWallet] = "#{@prefix}-#{params[:creditWallet]}"
      end
      return params
    end

    private

    def self.send_request(uri, params, options={}, &block)

      if options[:debug]
        puts '--- SENT ---'
        puts params.to_yaml
        puts '------------'
      end

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'application/json; charset=utf-8'})
      req.body = params.to_json
      res = http.request(req)
      json = JSON.parse(res.body)

      if options[:debug]
        puts '--- RECEIVED ---'
        puts json.to_yaml
        puts '----------------'
      end

      case res
      when Net::HTTPSuccess then
        unless (json['d']['E'])
          if block_given?
            return block.call(json['d'])
          else
            return [json['d'], nil]
          end
        else
          return [nil, {code: json['d']['E']['Code'], msg: json['d']['E']['Msg'] }]
        end
      else
        code2msg = {
          '400' => 'Bad Request : The server cannot or will not process the request due to something that is perceived to be a client error',
          '403' => 'IP is not allowed to access Lemon Way\'s API, please contact support@lemonway.fr',
          '404' => 'Check that the access URLs are correct. If yes, please contact support@lemonway.fr',
          '500' => 'Lemon Way internal server error, please contact support@lemonway.fr'
        }
        return [nil, {code: res.code, msg: json['Message'] || code2msg[res.code] || 'Unknown error' }]
      end
    end

    # class Error < Exception; end
  end

end

