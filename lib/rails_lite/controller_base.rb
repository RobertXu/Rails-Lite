require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require 'active_support/inflector'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise "Double Render" if self.already_built_response?
    self.res.content_type = type
    self.res.body = content
    @already_built_response = true
    self.session.store_session(self.res)
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    raise "redirect loop" if self.already_built_response?
    self.res.status = 302
    self.res["Location"] = url.to_s
    @already_built_response = true
    self.session.store_session(self.res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    file_name = "views/#{self.class.name.underscore}/#{template_name.to_s}.html.erb"
    contents = File.read(file_name)
    render_template = ERB.new(contents)
    b = binding()
    render_content(render_template.result(b), "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(self.req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end
end
