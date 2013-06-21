class ErrorController < ApplicationController
  
  public
  def no_method_error
    raise NoMethodError.new("Some Message")
  end
  def argument_error
    raise ArgumentError.new("Another Message")
  end
end
