module Helper
  def format_date(date)
    date.strftime('%m月%d日')
  end

  def to_unix_ts(date)
    date.to_time.to_i
  end
end
