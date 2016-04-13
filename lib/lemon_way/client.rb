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
      define_method(action.underscore.to_sym) do |*args,  &block|
        self.class.send_request(@uri, @auth, action, *args, &block)
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

    end

    private

    def self.send_request(uri, auth, method_name, version, params, opts={}, &block)

      params = auth.merge({
        version: version
      }).merge(params).merge(opts)

      puts '------'
      y params
      puts '------'

      uri = URI.parse("#{uri}/#{method_name}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'application/json; charset=utf-8'})
      req.body = params.to_json
      res = http.request(req)
      json = JSON.parse(res.body)

      case res
      when Net::HTTPSuccess then
        unless (json['d']['E'])
          if block_given?
            return block.call(json['d'])
          else
            return {success: true, data: json['d']}
          end
        else
          return {success: false, code: json['d']['E']['Code'], msg: json['d']['E']['Msg'] }
        end
      else
        code2msg = {
          '400' => 'Bad Request : The server cannot or will not process the request due to something that is perceived to be a client error',
          '403' => 'IP is not allowed to access Lemon Way\'s API, please contact support@lemonway.fr',
          '404' => 'Check that the access URLs are correct. If yes, please contact support@lemonway.fr',
          '500' => 'Lemon Way internal server error, please contact support@lemonway.fr'
        }
        return {success: false, code: res.code, msg: json['Message'] || code2msg[res.code] || 'Unknown error' }
      end
    end

    class Error < Exception; end
  end

end

