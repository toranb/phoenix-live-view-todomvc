module.exports = {
  purge: [
    '../lib/todo_web/live/**/*.ex',
    '../lib/todo_web/templates/layout/root.html.heex',
    '../lib/todo_web/templates/page/index.html.eex',
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        "todo-blue": "#00b9ff",
        "todo-black": "#4a5860",
        "todo-info": "#f2f5f7",
      },
    },
  },
  variants: {
    extend: {
      padding: ['last'],
      borderWidth: ['last'],
      borderRadius: ['last', 'first'],
      backgroundColor: ['first'],
    }
  },
  plugins: [
    require('@tailwindcss/line-clamp'),
  ],
};
