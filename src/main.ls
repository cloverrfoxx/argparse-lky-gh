/* argparse
 * no introductions required, have fun
 */

/* -= logic starts here =- */

ArgParser() = {
    parser = {};

    values = [];
    names = {};
    positionals = {};
    positionalOrder = [];

    getValue(name) =
        if names.hasIndex(name)
            return values[names[name]];
    parser.getValue = @getValue;

    setValue(name, value) =
        if names.hasIndex(name) {
            values[names[name]] = value;
            return self
        };
    parser.setValue = @setValue;

    getPositional(name) =
        if positionals.hasIndex(name)
            return values[positionals[name]];
    parser.getPositional = @getPositional;

    setPositional(name, value) =
        if positionals.hasIndex(name) {
            values[positionals[name]] = value;
            return self
        };
    parser.setPositional = @setPositional;

    parser.addArg(longNames, default = null, shortNames) = {
        if !@shortNames shortNames = [];
        idx = values.len;
        values.push(default);
        for name in longNames + shortNames
            outer.names[name] = idx;
        return self
    };

    parser.addPositional(name) = {
        idx = values.len;
        values.push(null);
        outer.positionals[name] = idx;
        positionalOrder.push(name);
        return self
    };

    parser.parse(args) = {
        posIdx = 0;
        i = 0;
        while i < args.len {
            arg = args[i];
            if arg.len > 2 && arg[:2] == '--' { // --long-arguments
                if !names.hasIndex(arg) return 'Unknown option: '+arg;

                idx = names[arg];

                if values[idx] == false values[idx] = true
                else if values[idx] == null {
                    i++;
                    if i >= args.len return 'Missing value for option: '+arg;
                    values[idx] = args[i]
                }
            } else if arg.len > 1 && arg[0] == '-' { // -short -a rguments
                if arg.len == 2 { // single flag
                    short = arg[1];
                    if !names.hasIndex(short) return 'Unknown option: '+short;

                    idx = names[short];

                    if values[idx] == false values[idx] = true
                    else if values[idx] == null {
                        i++;
                        if i >= args.len return 'Missing value for option: '+short;
                        values[idx] = args[i]
                    }
                } else // multiple flags
                    for short in arg[1:] {
                        if !names.hasIndex(short) return 'Unknown option: '+short;

                        idx = names[short];

                        if values[idx] == false values[idx] = true
                        else if values[idx] == null {
                            i++;
                            if i >= args.len return 'Missing value for option: '+short;
                            values[idx] = args[i]
                        }
                    };
            } else { // positional arguments
                if posIdx >= positionalOrder.len return 'Too many positional arguments.';

                posName = positionalOrder[posIdx];
                idx = positionals[posName];
                values[idx] = arg;

                posIdx++
            };
            i++;
        };

        return 0
    };

    return parser
};