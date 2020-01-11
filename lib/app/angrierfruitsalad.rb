require "app/angrierfruitsalad/version"

# stdlib stuff
require 'set'

# rdf stuff
require 'rdf'
require 'rdf/kv'
require 'rdf/renderer'

# uri stuff
require 'uri'
require 'uri/urn/uuid'

# rack stuff
require 'rack/request'
require 'rack/response'

class App::AngrierFruitSalad
  private

  # here are some default prefixes so we aren't left out in the cold
  PREFIXES = {
    rdf:  RDF::RDFV,
    rdfs: RDF::RDFS,
    owl:  RDF::OWL,
    xsd:  RDF::XSD,
    xhv:  RDF::Vocab::XHV,
  }

  # how many times have i written this
  UUID         = '[0-9A-Fa-f]{8}(?:-[0-9A-Fa-f]{4}){4}[0-9A-Fa-f]{8}'.freeze
  UUID_PATH    = "^/+(#{UUID})\\b".freeze
  URN_PREFIX   = "[Uu][Rr][Nn]:[Uu]{2}[Ii][Dd]:".freeze
  UUID_URN     = "#{URN_PREFIX}#{UUID}".freeze
  UUID_PATH_RE = /#{UUID_PATH}/o
  UUID_URN_RE  = /(?:#{URN_PREFIX})?(#{UUID})/o

  # Turn a URI containing a UUID as its path into a urn:uuid.
  # @param uri [URI, RDF::URI, #path] object containing the UUID
  # @param rdf [true, false] Whether RDF::URI or vanilla URI
  # @return [RDF::URI,URI::URN::UUID] the UUID URN in question
  #
  def coerce_uuid_urn uri, rdf: true
    raise ArgumentError, "This must be a path URI" unless uri.respond_to? :path
    m = UUID_PATH_RE.match(uri.path) or raise ArgumentError,
      "#{uri} does not match UUID pattern"
    cls = rdf ? RDF::URI : URI
    cls.parse "urn:uuid:#{m[1].downcase}"
  end

  # Take a UUID URN and turn it back into an HTTP URL with a UUID as its path.
  # @param uuid [String, URI, RDF::URI] a UUID or UUID URN
  # @param base [URI, RDF::URI] the base URI for the operation
  # @return [URI,RDF::URI] the HTTP(S) URL
  #
  def coerce_uuid_http uuid, base, rdf: false
    raise ArgumentError, "#{base} (#{base.class} not a URI)" unless
      [String, URI, RDF::URI].any? { |c| base.is_a? c }
    base = URI(base.to_s)

    m = UUID_URN_RE.match(uuid.to_s) or raise ArgumentError,
      "#{uuid} is not recognizable as a UUID"

    out = base + m[1].downcase

    rdf ? RDF::URI(out.to_s) : out
  end

  # Dispatcher method for UUIDs (GET HEAD POST) and 405 for the rest.
  # @param req [Rack::Request]
  # @return [Rack::Response]
  def uuid req
    # get head post and 405
    return uuid_get  req if %w[GET HEAD].include? req.request_method
    return uuid_post req if req.post?

    Rack::Response.new "We do not respond to #{req.request_method} requests.",
      405, { 'Content-Type' => 'text/plain' }
  end

  # Response to (assumes) GET for UUIDs.
  # @param req [Rack::Request]
  # @return [Rack::Response]
  def uuid_get req
    subject = coerce_uuid_urn req.get_header 'REQUEST_URI'

    
    # this is how we imagine this thing working
    doc = @renderer.process subject,
      type: req.get_header('HTTP_ACCEPT'),
      language: req.get_header('HTTP_ACCEPT_LANGUAGE')

    type = 'text/plain'
    case doc
    when Nokogiri::XML::Node
      doc  = doc.to_xml
      type = 'application/xhtml+xml'
    when Hash
      require 'json'
      doc  = doc.to_json
      type = 'application/ld+json'
    when RDF::Writer
      # set type based on what kind of writer it is?
    else
      doc = doc.to_s
    end

    # uhhh do we even wanna try for 304/206/etc?
    Rack::Response.new doc, 200, { 'Content-Type' => type }
  end

  # Response to (assumes) POST for UUIDs.
  # @param req [Rack::Request]
  # @return [Rack::Response]
  def uuid_post req
    # return 501 not implemented if content type is other than a form
    return Rack::Response.new "Unhandled body type #{req.media_type}", 501,
      { 'Content-Type' => 'text/plain' } unless req.form_data?

    kv = RDF::KV.new subject: req.request_uri
    begin
      patch = kv.process req.POST
    rescue RDF::KV::Error => e
      return Rack::Response.new "Malformed RDF-KV protocol: #{e}", 409,
        { 'Content-Type' => 'text/plain' }
    end

    begin
      patch.apply repo
    rescue e
      return Rack::Response.new "Couldn't patch the graph: #{e}", 500,
        { 'Content-Type' => 'text/plain' }
    end

    Rack::Response.new [], 303, { 'Location' => req.request_uri }
  end

  # Response to everything else
  def default req
  end

  # Coerce a prefix map into a proper `{ symbol: RDF::Vocabulary(...) }` form.
  # @param arg [nil, Hash, #to_h] the putative prefixes
  # @return [Hash] the coerced prefixes
  def coerce_prefixes arg
    arg ||= {}

    raise ArgumentError,
      "Prefixes must be a Hash or hashable, not #{arg.class}" unless
      arg.is_a? Hash or arg.respond_to? :to_h
    arg = arg.to_h

    arg.map do |k, v|
      raise ArgumentError,
        "Key must be nil or a Symbol or symbol-able" unless
        k.nil? or k.is_a? Symbol or k.respond_to? :to_sym

      k = k.to_sym if k
      v = case v
          when RDF::Vocabulary
            v
          when RDF::URI
            RDF::Vocabulary.new v
          when -> x { x.respond_to? :to_s }
            RDF::Vocabulary.new v.to_s
          else
            raise ArgumentError,
              "Invalid value #{v.inspect} for key #{k.inspect}"
          end
      [k, v]
    end.to_h
  end

  public

  attr_reader :repo, :prefixes, :renderer

  def initialize repo: nil, prefixes: {}
    @repo = repo ||= RDF::Repository.new
    raise ArgumentError,
      "Repository is not an RDF::Repository but a #{repo.inspect}" unless
      repo.is_a? RDF::Repository
    @prefixes = PREFIXES.merge coerce_prefixes prefixes
    @renderer = RDF::Renderer.new prefixes: @prefixes
  end

  def call env
    req = Rack::Request.new env

    # duh uuid
    return uuid(req).finish if UUID_PATH_RE.match? req.request_uri.path

    Rack::Response.new 'Fail tromboooooone',
      404, { 'Content-Type' => 'text/plain' }
  end
end
