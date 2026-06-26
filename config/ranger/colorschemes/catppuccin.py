from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import (
    default_colors, normal, bold, reverse,
    black, red, green, yellow, blue, magenta, cyan, white, default,
)


class CatppuccinMocha(ColorScheme):
    """Catppuccin Mocha colorscheme for ranger."""

    progress_bar_color = blue

    def use(self, context):
        fg, bg, attr = default_colors

        if context.reset:
            return default_colors

        elif context.in_browser:
            attr = reverse if context.selected else normal

            if context.empty or context.error:
                fg = red
            if context.border:
                fg = default
                attr = normal
            if context.media:
                fg = yellow if context.image else magenta
            if context.container:
                fg = red
            if context.directory:
                attr |= bold
                fg = blue
            elif context.executable and not any(
                (context.media, context.container, context.fifo, context.socket)
            ):
                attr |= bold
                fg = green
            if context.socket:
                fg = magenta
                attr |= bold
            if context.fifo or context.device:
                fg = yellow
                attr |= bold
            if context.link:
                fg = cyan if context.good else magenta
            if context.tag_marker and not context.selected:
                attr |= bold
                fg = red if fg not in (red, magenta) else white
            if not context.selected and context.cut:
                attr |= bold
                fg = red
            if not context.selected and context.copied:
                attr |= bold
                fg = yellow
            if context.main_column:
                if context.selected:
                    attr |= bold
                if context.marked:
                    attr |= bold
                    fg = yellow
            if context.badinfo:
                fg = magenta if not (attr & reverse) else bg

        elif context.in_titlebar:
            if context.hostname:
                fg = red if context.bad else green
            elif context.directory:
                fg = blue
            elif context.tab:
                if context.good:
                    bg = green
            elif context.link:
                fg = cyan
            attr |= bold

        elif context.in_statusbar:
            if context.permissions:
                fg = cyan if context.good else magenta
            if context.marked:
                attr |= bold | reverse
                fg = yellow
            if context.frozen:
                attr |= bold | reverse
                fg = cyan
            if context.message:
                if context.bad:
                    attr |= bold
                    fg = red
            if context.loaded:
                fg = context.vcsfile if context.vcsfile is not None else green
            if context.vcsinfo:
                fg = blue
                attr &= ~bold
            if context.vcscommit:
                fg = yellow
                attr &= ~bold
            if context.vcsdate:
                fg = cyan
                attr &= ~bold

        if context.text and context.highlight:
            attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = blue
            if context.selected:
                attr |= reverse
            if context.loaded:
                fg = context.vcsfile if context.vcsfile is not None else green

        return fg, bg, attr
