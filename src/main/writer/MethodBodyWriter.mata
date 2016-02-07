vers 11.2

matamac
matainclude DoFileWriter Template

mata:

class `MethodBodyWriter' {
	public:
		void init(), write()

	private:
		`RS' position
		`SR' tokens
		pointer(`DoFileWriterS') scalar out
		pointer(`TemplateS') scalar templat

		`SS' ltrim(), rtrim()
		`SS' token()
		`SR' token_tokens(), lines(), line_tokens()
		`BooleanS' eregexm()
		void tokenize(), trim_tag_line_spaces_and_tabs(), error_tag_line(),
			trim_tag_line_eols()
		void write_tag(), write_text()
}

`BooleanS' `MethodBodyWriter'::eregexm(`SS' s, `SS' regex)
{
	`SS' eregex
	eregex = regex
	eregex = subinstr(eregex, "\t", char(9), .)
	eregex = subinstr(eregex, "\n", char(10), .)
	return(regexm(s, eregex))
}

`SS' `MethodBodyWriter'::ltrim(`SS' s)
{
	`RS' i
	for (i = 1; eregexm(substr(s, i, 1), "[ \t]"); i++)
		;
	return(substr(s, i, .))
}

`SS' `MethodBodyWriter'::rtrim(`SS' s)
{
	`RS' i
	for (i = strlen(s); eregexm(substr(s, i, 1), "[ \t]"); i--)
		;
	return(substr(s, 1, i))
}

void `MethodBodyWriter'::error_tag_line(`RS' i)
{
	printf("\n{txt}Template: {res}%s\n", templat->method()->name())
	printf("{txt}Tag:\n\n")
	printf("{cmd}<%%%s%%>\n\n", tokens[i])
	errprintf("<%% %%> tags must occupy the entire line\n")
	_error(9)
}

/*
<% %> tags (not <%= %>) tags must occupy the entire line.

Good:

<% i = 1 %>
Hello world!

Bad:

Hello <% i = 1 %> world!

We should not write the white space surrounding these tag lines.
*/
void `MethodBodyWriter'::trim_tag_line_spaces_and_tabs(`RS' i)
{
	if (substr(tokens[i], 1, 1) == "=")
		return

	if (i - 2 > 0) {
		tokens[i - 2] = rtrim(tokens[i - 2])
		if (i - 2 == 1 && tokens[i - 2] == "" ||
			substr(tokens[i - 2], -1, 1) == char(10))
			/* good */ ;
		else
			error_tag_line(i)
	}

	if (i + 2 > length(tokens))
		error_tag_line(i)
	tokens[i + 2] = ltrim(tokens[i + 2])
	if (substr(tokens[i + 2], 1, 1) != char(10))
		error_tag_line(i)
}

void `MethodBodyWriter'::trim_tag_line_eols()
{
	`RS' i
	`BooleanS' tag_line
	for (i = 1; i <= length(tokens); i++) {
		if (tokens[i] == "<%") {
			tag_line = substr(tokens[++i], 1, 1) != "="
			assert(tokens[++i] == "%>")
			if (tag_line) {
				assert(substr(tokens[++i], 1, 1) == char(10))
				tokens[i] = substr(tokens[i], 2, .)
			}
		}
	}
}

void `MethodBodyWriter'::tokenize(`SS' body)
{
	`RS' i
	`BooleanS' inside
	`Tokenizer' t

	t = tokeninit("", ("<%", "%>"), "", `False', `False')
	tokenset(t, body)
	tokens = tokengetall(t)

	// `True' if we are within a set of <% %> tags and `False' if not.
	inside = `False'
	for (i = 1; i <= length(tokens); i++) {
		if (tokens[i] == "<%") {
			if (inside)
				_error("nested tags not allowed")
			inside = `True'
		}
		else if (tokens[i] == "%>") {
			if (!inside)
				_error("%> without <%")
			inside = `False'
		}
		else if (inside)
			trim_tag_line_spaces_and_tabs(i)
	}

	trim_tag_line_eols()
}

void `MethodBodyWriter'::init(`TemplateS' templat, `DoFileWriterS' out)
{
	this.templat = &templat
	tokenize(templat.body())
	this.out = &out
}

`SS' `MethodBodyWriter'::token()
	return(tokens[position])

`SR' `MethodBodyWriter'::token_tokens(`Tokenizer' t)
{
	tokenset(t, token())
	return(tokengetall(t))
}

// Converts a string that contains end-of-line characters to a rowvector of
// lines.
`SR' `MethodBodyWriter'::lines()
	return(token_tokens(tokeninit(char(10), "", "", `False', `False')))

// Converts a string that contains end-of-line characters to a rowvector of
// lines, retaining end-of-line characters as separate elements.
`SR' `MethodBodyWriter'::line_tokens()
	return(token_tokens(tokeninit("", char(10), "", `False', `False')))

void `MethodBodyWriter'::write_tag()
{
	`RS' i
	`SR' lines

	if (substr(token(), 1, 1) == "=") {
		out->put(sprintf("write(%s)", strtrim(substr(token(), 2, .))))
		return
	}

	lines = lines()
	for (i = 1; i <= length(lines); i++)
		out->put(lines[i])
}

void `MethodBodyWriter'::write_text()
{
	`RS' i
	`SS' line
	`SR' tokens

	if (token() == "")
		return

	pragma unset line
	tokens = line_tokens()
	for (i = 1; i <= length(tokens); i++) {
		if (tokens[i] != char(10))
			line = specialexp(tokens[i])
		else {
			out->put(sprintf("put(%s)", line))
			line = ""
		}
	}
	if (line != "")
		out->put(sprintf("write(%s)", line))
}

void `MethodBodyWriter'::write()
{
	`BooleanS' inside
	inside = `False'
	for (position = 1; position <= length(tokens); position++) {
		if (token() == "<%")
			inside = `True'
		else if (token() == "%>")
			inside = `False'
		else {
			if (inside)
				write_tag()
			else
				write_text()
		}
	}
}

end
