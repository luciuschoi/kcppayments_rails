# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module KcppaymentsRails
  class Client
    # 서버-서버 통신용 기본 클라이언트 (승인/취소 등)
    def initialize(site_cd: KcppaymentsRails.configuration.site_cd, site_key: KcppaymentsRails.configuration.site_key, gateway_url: KcppaymentsRails.configuration.gateway_url)
      @site_cd = site_cd
      @site_key = site_key
      @gateway_url = gateway_url
    end

    def approve(params)
      post("/center/pp_ax_hub.jsp", params)
    end

    def cancel(params)
      post("/center/pp_ax_hub.jsp", params.merge(type: "cancel"))
    end

    private

    def post(path, params)
      uri = URI.join(@gateway_url, path)
      req = Net::HTTP::Post.new(uri)
      req.set_form_data(params.merge(site_cd: @site_cd, site_key: @site_key))

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      res = http.request(req)
      parse_response(res)
    end

    def parse_response(res)
      content_type = res["Content-Type"]
      if content_type&.include?("json")
        JSON.parse(res.body)
      else
        # KCP는 key=value\n 형태도 반환함
        res.body.to_s.split(/\r?\n/).map { |l| l.split("=", 2) }.to_h
      end
    end
  end
end


