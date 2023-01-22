function decimal_years = get_decimal_years(dates)
    if ~isa(dates(1), 'datetime')
        dates = datetime(dates);
    end
    [y, m, d] = ymd(dates);
    decimal_years = y + m / 12 + d / 365.2425;
end