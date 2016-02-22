require 'csv'

module ArrayToCSV
  module_function

  def to_s(klass, items)
    CSV.generate do |csv|
      csv << klass.header

      items.each do |item|
        csv << klass.row(item)
      end
    end
  end
end
