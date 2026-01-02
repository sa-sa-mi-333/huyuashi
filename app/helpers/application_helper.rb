module ApplicationHelper
    # deviseのresource_nameを定義する
    def resource_name
        :user
    end
    def resource
        @resource ||= User.new
    end
    def devise_mapping
        @devise_mapping ||= Devise.mappings[:user]
    end

    # ページタイトルを定義
    def page_title(title = "")
        base_title = "ふゆあし"
        title.present? ? "#{title} | #{base_title}" : base_title
    end
end
