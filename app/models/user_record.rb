class UserRecord < ApplicationRecord
    belongs_to :user
    belongs_to :snow_station,
                foreign_key: :station_number,
                primary_key: :station_number
end
