/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{astro,html,js,jsx,ts,tsx,md,mdx}'],
  darkMode: 'class',
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui', 'Segoe UI', 'Roboto', 'sans-serif'],
      },
      colors: {
        // Terracotta Clay — matches the GutCheck app default palette.
        brand: {
          50:  '#fdf5ee',
          100: '#fbe8d6',
          200: '#f6cfa8',
          300: '#f1b179',
          400: '#ea8f51',
          500: '#d97757',
          600: '#c35f3d',
          700: '#a04a30',
          800: '#7d3b27',
          900: '#5c2d1e',
          950: '#311509',
        },
      },
      boxShadow: {
        'glow': '0 0 0 1px rgba(217,119,87,0.25), 0 20px 60px -20px rgba(217,119,87,0.35)',
        'soft': '0 1px 2px rgba(15,23,42,0.04), 0 8px 30px -10px rgba(15,23,42,0.10)',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-8px)' },
        },
        'fade-up': {
          '0%': { opacity: '0', transform: 'translateY(8px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
      animation: {
        float: 'float 6s ease-in-out infinite',
        'fade-up': 'fade-up 0.5s ease-out both',
      },
    },
  },
  plugins: [],
};
