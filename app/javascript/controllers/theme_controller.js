import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
    // Check for saved theme in localStorage
    console.log('connected');
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'dark') {
      document.documentElement.classList.add('dark');
    }
  }

  toggle() {
    console.log('click toggle');
    document.documentElement.classList.toggle('dark');

    // Save the theme preference in localStorage
    if (document.documentElement.classList.contains('dark')) {
      localStorage.setItem('theme', 'dark');
    } else {
      localStorage.setItem('theme', 'light');
    }
  }
}
