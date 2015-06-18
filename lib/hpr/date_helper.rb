module Hpr
  module DateHelper
    DATE_FORMAT = "%d.%m.%Y".freeze

    def str_to_date(str)
      begin
        Date.strptime(str, DATE_FORMAT)
      rescue ArgumentError; end
    end
  end
end
