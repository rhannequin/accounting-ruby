# Accounting

    bundle install
    cp config.example.csv config.csv
    cp data/data.example.csv data/data.csv
    bundle exec rackup

Open [localhost:9292](http://localhost:9292).

To myself, may be useful:

    data = {}
    SmarterCSV.process('tmp.csv', chunk_size: 10000, headers_in_file: true, file_encoding: 'utf-8', col_sep: ';', row_sep: "\n", strip_whitespace: true, key_mapping: {label: :label, value: :price, date: :date, means: :way, categories: :categories}) do { |chunck| data = chunck }
    CSV.open('data.csv', 'wb', col_sep: ';') { |csv| data.each { |e| e = {date: Date.strptime(e[:date], '%Y-%m-%d').strftime('%d/%m/%y'), label: e[:label], price: e[:price], way: e[:way], categories: e[:categories]}; csv << e.values } }
