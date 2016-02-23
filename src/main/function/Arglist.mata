vers 11.2

matamac
matainclude Arg

mata:

class `Arglist' {
	public:
		`RS' length()
		`SS' tostring()
		pointer(`ArgS') scalar get()
		void init()

	private:
		pointer(`ArgS') rowvector args
		`SS' strip_comments()
}

`SS' `Arglist'::strip_comments(`SS' arglist)
{
	`RS' i
	`SS' strip
	`SR' tokens

	pragma unset strip
	tokens = tokens(arglist, char(10) + char(13))
	for (i = 1; i <= (::length(tokens)); i++)
		if (!regexm(tokens[i], sprintf("^[ %s]*//", char(9))))
			strip = strip + tokens[i]

	return(strip)
}

void `Arglist'::init(`SS' arglist)
{
	`RS' i
	`SR' tokens
	`Tokenizer' t

	t = tokeninit(",", "", "", `False', `False')
	tokenset(t, strip_comments(arglist))
	tokens = tokengetall(t)

	args = J(1, ::length(tokens), NULL)
	for (i = 1; i <= (::length(tokens)); i++) {
		args[i] = &(`Arg'())
		args[i]->init(tokens[i])
	}
}

`RS' `Arglist'::length()
	return(::length(args))

pointer(`ArgS') scalar `Arglist'::get(`RS' index)
	return(args[index])

`SS' `Arglist'::tostring()
{
	`RS' i
	`SS' s
	pragma unset s
	for (i = 1; i <= length(); i++) {
		if (i > 1)
			s = s + ", "
		s = s + args[i]->tostring()
	}
	return(s)
}

end
