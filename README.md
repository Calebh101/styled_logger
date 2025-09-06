## Styled Logger

This package is designed to help you avoid using the default Dart `print` method, and put some color and format in your logs.

## Features

- Web support (uses package `web` and the `console` API)
- Multiline logs have sections
- Error/warning codes
- Verbose and bold messages

## Usage

Each method and variable is a static member of the `Logger` class.

`Logger.enabled`: Returns `true` if non-public logging is enabled, `false` if not.

`Logger.verboseEnabled`: Returns `true` if non-public *and* verbose logging is enabled, `false` if not.

`Logger.publicLogLevel`: Returns the current public log level. This will be explained more in `Logger.setPublicLogLevel`.

`Logger.dateStringFunction`: This variable is used for formatting `DateTime`s. This by default just uses the ISO 8601 string, but you can make this prettier too.

`Logger.onPrint`, `.onWarn`, `.onAny`, etcetera are covered in their respective DartDocs.

`Logger.print` will print the current value, and optional "attachments" (extra data). This will print the message and attachments to the console. `Logger.print` requires logging to be enabled.

`Logger.warn` will print a warning message to the console (unsurprisingly). This function, along with all the other logging ones, also takes an `attachments` input. However, this one (and `Logger.error`) take a `code` input. This can be any object, and is printed with the message, in the title. This requires that either logging is enabled, `Logger.publicLogLevel` is at least `PublicLogLevel.warning`.

`Logger.error` is like `Logger.warn`, but it's red. This requires that either logging is enabled, `Logger.publicLogLevel` is at least `PublicLogLevel.error`.

`Logger.verbose` will print a verbose message to the console. These messages are dimmed (using the ANSI effect of `2`). This requires that both logging *and* verbose are enabled.

`Logger.important` is like `Logger.print`, but it's **bold**. This requires that either logging is enabled, or `Logger.publicLogLevel` is at least `PublicLogLevel.important`.

`Logger.enable` enables non-public logging.

`Logger.disable` disabled non-public logging.

`Logger.setEnabled` sets non-public logging to either enabled or disabled, depending on the input.

`Logger.enableVerbose` enables verbose logging.

`Logger.disableVerbose` disables verbose logging.

`Logger.setVerbose` sets verbose logging to either enabled or disabled, depending on the input.

`Logger.setPublicLogLevel` sets the public log level, or basically, **what is logged even when logging is disabled**. For example, if this is set to `PublicLogLevel.warning`, then both warning and error logs will be shown. If this is set to `PublicLogLevel.error`, then only error logs are shown. If this is set to `PublicLogLevel.none`, then no logs are shown when logging is disabled.