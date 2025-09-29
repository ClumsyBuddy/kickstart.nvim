import { Component } from '@angular/core';

@Component({
  selector: 'app-example',
  template: `   
    <div class="flex items-center justify-center bg-blue-500 hover:bg-blue-600 transition-colors">
      <h1 [ngClass]="titleClasses" (click)="onClick($event)">
        {{ title }}
      </h1>    
      <button 
        class="px-4 py-2 text-white bg-green-500 rounded-lg shadow-md hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-green-300"
        [style.color]="textColor"
        (click)="handleClick()">
        Click me
      </button>
    </div>
  `,
  styles: [`
    .custom-title {
      font-size: 2rem;
      font-weight: bold;
      color: #333;
    }
    
    .highlight {
      background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
  `],
  styleUrls: ['./example.component.scss']
})
export class ExampleComponent {
  title = 'Angular with Otter';
  textColor = 'white';

  titleClasses = {
    'custom-title': true,
    'highlight': false
  };

  onClick(event: MouseEvent): void {
    console.log('Title clicked:', event);
    this.titleClasses.highlight = !this.titleClasses.highlight;
  }

  handleClick(): void {
    console.log('Button clicked');
  }
}
