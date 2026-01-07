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

    # ファイル名とオプションを指定してsvg画像をインライン要素として読み込む
    def svg_tag(filename, options = {})
      path = Rails.root.join("app/assets/images/icons", "#{filename}.svg")
      if File.exist?(path)
        File.read(path).html_safe
      else
        "<!-- SVG画像が読み込めませんでした -->".html_safe
      end
    end
end
