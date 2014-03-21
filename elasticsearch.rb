#!/usr/bin/env ruby
#
# Sensu Elasticsearch Handler

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'net/http'
require 'timeout'
require 'digest/md5'
require 'date'

class Elasticsearch < Sensu::Handler
  def host
    settings['elasticsearch']['host'] || 'localhost'
  end

  def port
    settings['elasticsearch']['port'] || 9200
  end

  def es_index
    settings['elasticsearch']['index'] || 'sensu'
  end

  def es_type
    settings['elasticsearch']['type'] || 'handler'
  end

  def es_id
    rdm = ((0..9).to_a + ("a".."z").to_a + ("A".."Z").to_a).sample(3).join
    Digest::MD5.new.update("#{rdm}")
  end

  def time_stamp
    d = DateTime.now
    d.to_s
  end

  def event_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def action_to_string
    @event['action'].eql?('resolve') ? 'RESOLVED' : 'ALERT'
  end

  def handle
    event = {
      :@timestamp => time_stamp,
      :date_time => time_stamp,
      :action => action_to_string,
      :name => event_name,
      :client => @event['client']['name'],
      :check_name => @event['check']['name'],
      :status => @event['check']['status'],
      :output => @event['check']['output'],
      :address => @event['client']['address'],
      :command => @event['check']['command'],
      :occurrences => @event['occurrences'],
      :flapping => @event['check']['flapping']
    }

    begin
      timeout(5) do
        uri = URI("http://#{host}:#{port}/#{es_index}/#{es_type}/#{es_id}")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.path, "content-type" => "application/json; charset=utf-8")
        request.body = JSON.dump(event)

        response = http.request(request)
        if response.code == '200'
          puts "elasticsearch post ok."
        else
          puts "elasticsearch post failure. status error code #=> #{response.code}"
        end
      end
    rescue Timeout::Error
      puts "elasticsearch timeout error."
    end
  end
end
