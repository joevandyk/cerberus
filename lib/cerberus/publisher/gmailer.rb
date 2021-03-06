require 'cerberus/publisher/base'

class Cerberus::Publisher::Gmailer < Cerberus::Publisher::Base
  def self.publish(state, manager, options)
    require 'gmailer'

    subject, body = Cerberus::Publisher::Base.formatted_message(state, manager, options)

    gopts = options[:publisher, :gmailer]
    recipients = gopts[:recipients]
    GMailer.connect(gopts) do |g|
      success = g.send(:to => recipients, :subject => subject, :body => body, :from => gopts[:recipients])

      raise 'Unable to send mail using Gmailer' unless success
    end
  end
end