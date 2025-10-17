import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['content', 'icon', 'tooltipWrapper', 'tooltipIcon', 'tooltipContent', 'buttonTooltip', 'buttonTooltipText', 'toggleButton'];
  static values = { expanded: { type: Boolean, default: false } };
  static classes = ['expanded'];

  toggle(event) {
    event.stopPropagation();
    this.expandedValue = !this.expandedValue;
  }

  expandedValueChanged() {
    if (this.expandedValue) {
      this.expand();
    } else {
      this.collapse();
    }
  }

  expand() {
    // Show content
    this.contentTarget.classList.remove('hidden');

    // Rotate icon
    if (this.hasIconTarget) {
      this.iconTarget.style.transform = 'rotate(180deg)';
    }

    // Update button tooltip text
    if (this.hasButtonTooltipTextTarget) {
      const expandedText = this.buttonTooltipTextTarget.dataset.toggleExpandedText;
      if (expandedText) {
        this.buttonTooltipTextTarget.textContent = expandedText;
      }
    }

    // Disable total tooltip when expanded (details are already visible)
    this.tooltipWrapperTargets.forEach(wrapper => {
      wrapper.classList.add('pointer-events-none');
    });
    this.tooltipIconTargets.forEach(icon => {
      icon.classList.add('opacity-30');
      icon.classList.remove('cursor-help', 'hover:text-primary-600');
    });
    this.tooltipContentTargets.forEach(content => {
      content.classList.add('!hidden');
    });

    // Add expanded class to element
    if (this.hasExpandedClass) {
      this.element.classList.add(...this.expandedClasses);
    }
  }

  collapse() {
    // Hide content
    this.contentTarget.classList.add('hidden');

    // Rotate icon back
    if (this.hasIconTarget) {
      this.iconTarget.style.transform = 'rotate(0deg)';
    }

    // Update button tooltip text
    if (this.hasButtonTooltipTextTarget) {
      const collapsedText = this.buttonTooltipTextTarget.dataset.toggleCollapsedText;
      if (collapsedText) {
        this.buttonTooltipTextTarget.textContent = collapsedText;
      }
    }

    // Re-enable total tooltip when collapsed
    this.tooltipWrapperTargets.forEach(wrapper => {
      wrapper.classList.remove('pointer-events-none');
    });
    this.tooltipIconTargets.forEach(icon => {
      icon.classList.remove('opacity-30');
      icon.classList.add('cursor-help', 'hover:text-primary-600');
    });
    this.tooltipContentTargets.forEach(content => {
      content.classList.remove('!hidden');
    });

    // Remove expanded class from element
    if (this.hasExpandedClass) {
      this.element.classList.remove(...this.expandedClasses);
    }
  }
}
