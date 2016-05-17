module Accounting
  class App
    module CsvHelper
      def csv_options
        {
          chunk_size: 10000,
          headers_in_file: true,
          file_encoding: 'utf-8',
          col_sep: ';',
          row_sep: "\n",
          strip_whitespace: true,
          key_mapping: { date: :date, objet: :reason, prix: :price, moyen: :way, catégories: :categories }
        }
      end

      def parse_data
        improved = nil
        SmarterCSV.process(File.join(settings.root, 'data.csv'), csv_options) do |chunk|
          improved = improve_chunk chunk
        end
        improved
      end

      def improve_chunk(chunk)
        chunk.map! do |c|
          c[:date] = Date.strptime(c[:date], '%d/%m/%y')
          c[:categories] = c[:categories].nil? ? [] : c[:categories].split(',').map(&:strip)
          c
        end
      end
    end
  end
end
