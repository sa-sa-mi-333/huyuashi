module ApplicationHelper
    #deviseのresource_nameを定義する
    def resource_name
        :user
    end    
    def resource
        @resource ||= User.new
    end
    def devise_mapping
        @devise_mapping ||= Devise.mappings[:user]
    end
end
