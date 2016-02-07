vers 11.2

matamac
matainclude Function

mata:

class `Template' {
	public:
		void init()
		pointer(`FunctionS') scalar method()
		`SS' body()

	private:
		`SS' body
		`FunctionS' method
		`SS' read_file()
		void parse_args(), validate_body()
}

`SS' `Template'::read_file(`SS' filename)
{
	`RS' length
	`SS' contents
	`FileHandleS' fh

	fh = fopen(filename, "r")
	fseek(fh, 0, 1)
	length = ftell(fh)
	fseek(fh, 0, -1)
	contents = fread(fh, length)
	fclose(fh)

	contents = subinstr(contents, char(13) + char(10), char(10), .)
	contents = subinstr(contents, char(13), char(10), .)

	return(contents)
}

// Splits the template into its arguments and body.
void `Template'::parse_args(`SS' contents, `SS' args, `SS' body)
{
	`RS' open, level, close, first, i
	`SS' c

	if (!regexm(contents, sprintf("^[ %s]*args\(", char(9) + char(10)))) {
		args = ""
		body = contents
		return
	}

	open = strpos(contents, "args(") + strlen("args")

	level = 1
	for (close = open + 1; level > 0 && close <= strlen(contents); close++) {
		c = substr(contents, close, 1)
		if (c == "(")
			level++
		else if (c == ")")
			level--
	}
	if (level > 0)
		_error("matching close parenthesis not found")
	close--

	args = substr(contents, open + 1, close - open - 1)

	pragma unset first
	for (i = close + 1; first == . && i <= strlen(contents); i++) {
		c = substr(contents, i, 1)
		if (c == char(10)) {
			first = i + 1
			if (first > strlen(contents))
				_error("template empty after argument list")
		}
		else if (c != " " && c != char(9))
			_error("new line expected after argument list end")
	}
	if (first == .)
		_error("template empty except for argument list")
	body = substr(contents, first, .)
}

void `Template'::validate_body()
{
	if (substr(body, -1, 1) != char(10))
		_error("template must end with an end-of-line character")
}

void `Template'::init(`SS' filename)
{
	`SS' args
	pragma unset args
	parse_args(read_file(filename), args, body)
	validate_body()
	method.init("void", pathrmsuffix(pathbasename(filename)), args)
}

pointer(`FunctionS') scalar `Template'::method()
	return(&method)

`SS' `Template'::body()
	return(body)

end
