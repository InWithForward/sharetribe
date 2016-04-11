require 'csv'

module ArrayToCSV
  module_function

  def generate(klass, items, args = {})
    CSV.generate do |csv|
      csv << klass.header

      items.each do |item|
        csv << klass.row(item, args)
      end
    end
  end
end
