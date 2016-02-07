vers 11.2

matamac

mata:

class `Arg' {
	public:
		`SS' type(), name(), tostring()
		`BooleanS' is_optional()
		void init()

	private:
		`SS' type, name
		`BooleanS' is_optional
}

void `Arg'::init(`SS' arg)
{
	`SS' copy
	`SR' tokens

	copy = arg
	copy = subinstr(copy, char(9),  " ", .)
	copy = subinstr(copy, char(10), " ", .)
	copy = subinstr(copy, char(13), " ", .)
	copy = strtrim(stritrim(copy))

	is_optional = substr(copy, 1, 1) == "|"
	if (is_optional)
		copy = strltrim(substr(copy, 2, .))

	tokens = tokens(copy)
	if (length(tokens) == 0)
		_error("no name")
	name = tokens[length(tokens)]

	if (length(tokens) == 1)
		type = "\`TM'"
	else
		type = invtokens(tokens[|1 \ length(tokens) - 1|])
}

`SS' `Arg'::name()
	return(name)

`SS' `Arg'::type()
	return(type)

`BooleanS' `Arg'::is_optional()
	return(is_optional)

`SS' `Arg'::tostring()
	return((is_optional ? "|" : "") + type + " " + name)

end
