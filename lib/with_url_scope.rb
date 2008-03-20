# WithUrlScope
module WithUrlScope
  
  mattr_accessor :current_scope
  mattr_accessor :current_overwrite_scope
  
  module UrlRewriter
    def self.included(base)
      puts("including UrlRewriter into #{base}")
      return if base.included_modules.include?(InstanceMethods)
      base.send(:include, InstanceMethods)
      base.alias_method_chain(:rewrite, :scope)
    end
    
    module InstanceMethods
      def rewrite_with_scope(options = {})
        options.reverse_merge!(WithUrlScope.current_scope || {})
        options.merge!(WithUrlScope.current_overwrite_scope || {})
        RAILS_DEFAULT_LOGGER.debug "Scoped rewrite: #{options.inspect}" unless WithUrlScope.current_scope.blank?
        rewrite_without_scope(options)
      end
    end
  end
  
  module UrlWriter
    def self.included(base)
      puts("including UrlWriter into #{base}")
      return if base.included_modules.include?(InstanceMethods)
      base.send(:include, InstanceMethods)
      base.alias_method_chain(:url_for, :scope)
    end
    
    module InstanceMethods
      def url_for_with_scope(options = {})
        options.reverse_merge!(WithUrlScope.current_scope || {})
        options.merge!(WithUrlScope.current_overwrite_scope || {})
        RAILS_DEFAULT_LOGGER.debug "Scoped url_for: #{options.inspect}" unless WithUrlScope.current_scope.blank?
        url_for_without_scope(options)
      end
    end
  end
  
  module UrlScopeHelper
    # adds parameters to every url generated within the block
    # by default the scope parameters will be overridden by the options passed to the call to url_for
    # if you want to override the options passed to url_for, you can pass those via :overwrite
    # Examples
    # <% with_url_scope(:return_to => request.uri) do %>
    #   <%= link_to 'Sign Up', signup_path %>
    #   <%= link_to 'Login', login_path %>
    # <% end %>
    # 
    # <% with_url_scope(:subdomain => 'www', :overwrite => {:only_path => false}) do %>
    #   <%= link_to 'Sign Up', signup_path %>
    #   <%= link_to 'Login', login_path %>
    # <% end %>
    #
    # UrlScopeHelper is also mixed into ActionController::Base so it can be used as an around_filter.
    def with_url_scope(scope = {})
      overwrite_scope = scope.delete(:overwrite) || {}
      old_scope = WithUrlScope.current_scope
      old_overwrite_scope = WithUrlScope.current_overwrite_scope
      WithUrlScope.current_scope = scope && scope.merge(old_scope || {})
      WithUrlScope.current_overwrite_scope = overwrite_scope && overwrite_scope.merge(old_overwrite_scope || {})
      logger.debug "URL Scope is #{WithUrlScope.current_scope.inspect}"
      logger.debug "URL Overwrite Scope is #{WithUrlScope.current_overwrite_scope.inspect}"
      begin
        yield
      ensure
        WithUrlScope.current_scope = old_scope
        WithUrlScope.current_overwrite_scope = old_overwrite_scope
      end
    end
  end
end