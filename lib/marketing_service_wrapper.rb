require "marketing_service_wrapper/version"
require 'net/http'
require 'uri'
require 'json'

module MarketingServiceWrapper
  class Base
    def self.site=(url)
      @site = url
    end

    def self.site
      @site
    end

    def self.restore_test_data
      uri = URI.join(MarketingServiceWrapper::Base.site, '/restore_test_data')
      http = Net::HTTP.new(uri.host, uri.port)
      http.post(uri.path, "test=true")
    end

    def companies
      companies = Net::HTTP.get_response(URI.join(MarketingServiceWrapper::Base.site, '/companies'))
      body = JSON.parse(companies.body)
      body["companies"].map do |b|
        Company.new(name: b["name"], id: b["id"])
      end
    end
  end

  class Company < OpenStruct
    def channels
      channels = Net::HTTP.get_response(URI.join(MarketingServiceWrapper::Base.site, '/channels', "?company_id=#{self.id}"))
      body = JSON.parse(channels.body)
      body["channels"].map do |b|
        Channel.new(name: b["name"], id: b["id"])
      end
    end

    def opt_ins
      opt_ins = Net::HTTP.get_response(URI.join(MarketingServiceWrapper::Base.site, '/opt_ins', "?company_id=#{self.id}"))
      body = JSON.parse(opt_ins.body)
      body["opt_ins"].map do |b|
        OptIn.new(b)
      end
    end
  end

  class Channel < OpenStruct
    def create_opt_in(first_name, last_name, email, mobile)
      uri = URI.join(MarketingServiceWrapper::Base.site, '/opt_ins/new', "?channel_id=#{self.id}")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({'opt_in[first_name]' => first_name, 'opt_in[last_name]' => last_name, 'opt_in[email]' => email, 'opt_in[mobile]' => mobile})
      http.request(request)
    end
  end

  class OptIn < OpenStruct
    def update(first_name, last_name, email, mobile)
      uri = URI.join(MarketingServiceWrapper::Base.site, '/opt_ins/edit')
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({'opt_in_id' => self._id, 'opt_in[first_name]' => first_name, 'opt_in[last_name]' => last_name, 'opt_in[email]' => email, 'opt_in[mobile]' => mobile})
      http.request(request)
    end

    def destroy
      uri = URI.join(MarketingServiceWrapper::Base.site, '/opt_ins/deactivate')
      http = Net::HTTP.new(uri.host, uri.port)
      http.post(uri.path, "opt_in_id=#{self._id}")
    end
  end
end
