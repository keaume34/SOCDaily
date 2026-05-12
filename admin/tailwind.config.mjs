/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{ts,tsx}"],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        ink: {
          50: "#f7f7f8",
          100: "#eeeef0",
          200: "#d8d8dd",
          300: "#a8a8b1",
          400: "#7a7a86",
          500: "#525261",
          600: "#3a3a47",
          700: "#262633",
          800: "#171723",
          900: "#0c0c14",
        },
      },
      fontFamily: {
        sans: [
          "ui-sans-serif",
          "system-ui",
          "Inter",
          "-apple-system",
          "BlinkMacSystemFont",
          "Segoe UI",
          "sans-serif",
        ],
        mono: [
          "ui-monospace",
          "SFMono-Regular",
          "Menlo",
          "Consolas",
          "monospace",
        ],
      },
      backgroundImage: {
        "gradient-deck":
          "linear-gradient(135deg, #0c0c14 0%, #171723 40%, #3a3a47 100%)",
      },
    },
  },
  plugins: [],
};
