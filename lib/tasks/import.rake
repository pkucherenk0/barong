# frozen_string_literal: true

require 'csv'

namespace :import do
  desc 'Load users from csv file.'
  task users: :environment do
    ### Parse options
    o = OptionParser.new

    o.banner = "Usage: rake import:users [=-csv 'file/imp_users.csv']"
    o.on('-csv PATH')
    args = o.order(ARGV) # protect from wrong params
    o.parse!(args)
    csv_table = File.read(args.last)
    logger = File.open('log/import_logger.log', 'w')

    CSV.parse(csv_table, headers: true).map.with_index do |row, index|
      u = User.new(email: row['email'], uid: row['uid'], password: row['password'])
      unless u.save
        logger.puts("USER #{row['email']} CREATION ON LINE #{index} FAILS:")
        logger.puts(u.errors.full_messages)
        logger.puts("\n\n")
        next
      end
      u.after_confirmation
    end

    logger.close
  end
end
