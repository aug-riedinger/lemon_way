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
        self.class.send_request(action, *args, &block)
      end
    end

    def initialize(opts = {})
      @@uri = URI.parse opts.delete(:uri)
      @@auth = {
        wlLogin: opts.delete(:wl_login),
        wlPass: opts.delete(:wl_pass),
        language: opts.delete(:language),
        walletIp: opts.delete(:ip) || (`curl ifconfig.co`).sub(/\n/, ''), 
        walletUa:  opts.delete(:user_agent) || ''
      }
    end

    private

    def self.send_request(method_name, version, params, opts={}, &block)
      @@auth.merge({
        version: version
      }).merge(params).merge(opts)

      uri = URI.parse("#{@@uri}/#{method_name}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'application/json', 'charset' => 'utf-8'})
      req.body = params.to_json
      res = http.request(req)

      case res
      when Net::HTTPSuccess then
        res = JSON.parse(res.body)['d']
        unless (res['E'])
          if block_given?
            return block.call(res)
          else
            return {success: true, data: res}
          end
        else
          return {success: false, code: res['E']['Code'], msg: res['E']['Msg'] }
        end
      else
        code2msg = {
          400 => 'Bad Request : The server cannot or will not process the request due to something that is perceived to be a client error',
          403 => 'IP is not allowed to access Lemon Way\'s API, please contact support@lemonway.fr',
          404 => 'Check that the access URLs are correct. If yes, please contact support@lemonway.fr',
          500 => 'Lemon Way internal server error, please contact support@lemonway.fr'
        }
        return {success: false, code: res.code, msg: code2msg[res.code.to_i] }
      end
    end

    class Error < Exception; end
  end

end

