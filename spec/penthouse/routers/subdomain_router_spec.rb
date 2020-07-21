require "spec_helper"
require "penthouse/routers/subdomain_router"
require "rack/request"

RSpec.describe Penthouse::Routers::SubdomainRouter do
  describe ".call" do
    it "should return the first sub-domain from the request" do
      request = double(Rack::Request, host: "example.host.name")
      expect(described_class.call(request)).to eq("example")
    end
  end
end
