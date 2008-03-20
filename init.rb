require 'with_url_scope'

ActionController::UrlRewriter.send(:include, WithUrlScope::UrlRewriter)
ActionController::UrlWriter.send(:include, WithUrlScope::UrlWriter)
ActionView::Base.send(:include, WithUrlScope::UrlScopeHelper)
ActionController::Base.send(:include, WithUrlScope::UrlScopeHelper)