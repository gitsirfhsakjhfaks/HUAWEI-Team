// Calculator.ets
@Entry
@Component
struct Calculator {
  @State currentInput: string = '0'     // 当前输入
  @State firstOperand: number = 0       // 第一个操作数
  @State operator: string = ''          // 当前操作符
  @State isNewInput: boolean = true     // 是否为新输入
  @State isScientificMode: boolean = false  // 是否为科学计算模式
  @State memoryValue: number = 0        // 内存值
  @State history: string[] = []         // 计算历史记录
  private scroller: Scroller = new Scroller();
  // 最大输入位数（单个数字）
  private MAX_NUMBER_LENGTH: number = 12

  // 最大表达式长度（包括操作符和空格）
  private MAX_EXPRESSION_LENGTH: number = 30

  // 处理数字按钮点击
  handleNumber(num: string) {

    // 如果当前显示错误，清空输入
    if (this.currentInput === 'Error') {
      this.currentInput = '0'
    }

    // 拆分当前输入以检查当前数字的长度
    const currentParts = this.currentInput.split(/[+\-×÷]/)
    const currentNumber = currentParts[currentParts.length - 1].trim()

    // 单个数字长度限制
    if (currentNumber.replace('.', '').length >= this.MAX_NUMBER_LENGTH) {
      return // 超过最大位数，不处理输入
    }

    // 处理小数点限制
    if (num === '.') {
      if (currentNumber.includes('.')) {
        return // 已存在小数点，不处理
      }
      if (currentNumber === '') {
        this.currentInput += '0.' // 补零
        this.isNewInput = false
        return
      }
    }

    if (this.isNewInput && this.currentInput.includes(' ')) {
      // 如果是新输入且当前输入包含操作符，追加数字
      this.currentInput += num;
    } else if (this.isNewInput) {
      // 如果是新输入且当前输入不包含操作符，覆盖输入
      this.currentInput = num;
    } else {
      // 不是新输入，追加数字
      this.currentInput += num;
    }
    this.isNewInput = false;
  }

  // 新增运算队列相关状态
  private numbers: number[] = []
  private operators: string[] = []

  // 处理操作符按钮点击
  handleOperator(op: string) {
    // 如果当前显示错误，清空输入
    if (this.currentInput === 'Error') {
      this.currentInput = '0'
      return
    }

    // 表达式总长度限制
    if (this.currentInput.length >= this.MAX_EXPRESSION_LENGTH) {
      this.currentInput = 'Error'
      return
    }

    // 移除末尾的空格
    this.currentInput = this.currentInput.trimEnd()

    // 获取最后一个操作符位置
    const lastOperatorIndex = this.currentInput.search(/[+\-×÷]\s*$/)

    if (lastOperatorIndex !== -1) {
      // 如果已存在操作符，替换最后一个操作符
      this.currentInput = this.currentInput.slice(0, lastOperatorIndex).trimEnd() + ` ${op} `
    } else if (!this.isNewInput) {
      // 追加操作符
      this.currentInput += ` ${op} `
    } else {
      // 初始状态或错误后输入操作符（例如输入负数）
      this.currentInput = `${this.currentInput} ${op} `
    }

    this.isNewInput = true
  }

  // 获取运算符优先级
  private getPriority(op: string): number {
    switch (op) {
      case '+':
      case '-':
        return 1
      case '×':
      case '÷':
        return 2
      case 'pow':
        return 3
      default:
        return 0
    }
  }

  // 执行计算
  calculate() {
    let calculationExpression = ''; // 用于存储计算式
    if (!this.isNewInput) {
      // 拆分 currentInput 为数字和操作符
      const parts = this.currentInput.split(/([+\-×÷])/).filter(part => part!== '');
      const numStack: number[] = [];
      const opStack: string[] = [];

      for (let i = 0; i < parts.length; i++) {
        const part = parts[i];
        const num = parseFloat(part);
        if (!isNaN(num)) {
          numStack.push(num);
          calculationExpression += part; // 添加数字到计算式
        } else {
          calculationExpression += part; // 添加操作符到计算式
          // 处理运算符优先级
          while (opStack.length > 0 && this.getPriority(opStack[opStack.length - 1]) >= this.getPriority(part)) {
            const num2 = numStack.pop()!;
            const num1 = numStack.pop()!;
            const op = opStack.pop()!;
            let result = 0;
            switch (op) {
              case '+': result = num1 + num2; break;
              case '-': result = num1 - num2; break;
              case '×': result = num1 * num2; break;
              case '÷':
                if (num2 === 0) {
                  this.currentInput = 'Error';
                  return;
                }
                result = num1 / num2;
                break;
              case 'pow': result = Math.pow(num1, num2); break;
            }
            numStack.push(result);
          }
          opStack.push(part);
        }
      }

      // 处理剩余的操作符
      while (opStack.length > 0) {
        const num2 = numStack.pop()!;
        const num1 = numStack.pop()!;
        const op = opStack.pop()!;
        let result = 0;
        switch (op) {
          case '+': result = num1 + num2; break;
          case '-': result = num1 - num2; break;
          case '×': result = num1 * num2; break;
          case '÷':
            if (num2 === 0) {
              this.currentInput = 'Error';
              return;
            }
            result = num1 / num2;
            break;
          case 'pow': result = Math.pow(num1, num2); break;
        }
        numStack.push(result);
      }

      if (numStack.length > 0) {
        let finalResult = numStack[0]

        // 处理超大/超小数的显示
        if (Math.abs(finalResult) >= 1e12 || (Math.abs(finalResult) < 1e-6 && finalResult !== 0)) {
          // 使用科学计数法，保留6位有效数字
          finalResult = Number(finalResult.toExponential(6))
        } else {
          // 对于普通数字，限制小数位数为8位
          finalResult = Number(parseFloat(finalResult.toFixed(8)))
        }

        this.history.push(`${calculationExpression} = ${finalResult}`)

        // 截断历史记录
        if (this.history.length > 5) {
          this.history.shift()
        }

        // 显示格式化后的结果
        this.currentInput = finalResult.toString()

        // 滚动到底部
        this.scrollToBottom()
      }
    }

    this.isNewInput = true;
  }

  // 清除输入
  clear() {
    if (this.currentInput === 'Error') {
      this.currentInput = '0'
    } else {
      // 原逻辑
      this.currentInput = '0'
      this.numbers = []
      this.operators = []
    }
    this.isNewInput = true
  }

  // 清除所有（包括历史记录）
  clearAll() {
    this.clear()
    this.history = []
    this.memoryValue = 0
  }

  // 退格功能
  backspace() {
    if (this.currentInput.length > 1) {
      this.currentInput = this.currentInput.slice(0, -1)
    } else {
      this.currentInput = '0'
      this.isNewInput = true
    }
  }

  // 科学计算功能
  scientificFunction(func: string) {
    const value = parseFloat(this.currentInput)
    let result: number = 0

    switch (func) {
      case 'sin':
        result = Math.sin(value * Math.PI / 180) // 角度转弧度
        break
      case 'cos':
        result = Math.cos(value * Math.PI / 180)
        break
      case 'tan':
        result = Math.tan(value * Math.PI / 180)
        break
      case 'sqrt':
        if (value < 0) {
          this.currentInput = 'Error'
          return
        }
        result = Math.sqrt(value)
        break
      case 'log':
        if (value <= 0) {
          this.currentInput = 'Error'
          return
        }
        result = Math.log10(value)
        break
      case 'ln':
        if (value <= 0) {
          this.currentInput = 'Error'
          return
        }
        result = Math.log(value)
        break
      case 'square':
        result = value * value
        break
    }

    this.currentInput = result.toString()
    this.isNewInput = true
  }

  // 内存功能
  memoryFunction(func: string) {
    switch (func) {
      case 'MS': // Memory Store
        this.memoryValue = parseFloat(this.currentInput)
        this.isNewInput = true
        break
      case 'MR': // Memory Recall
        this.currentInput = this.memoryValue.toString()
        this.isNewInput = true
        break
      case 'M+': // Memory Add
        this.memoryValue += parseFloat(this.currentInput)
        this.isNewInput = true
        break
      case 'M-': // Memory Subtract
        this.memoryValue -= parseFloat(this.currentInput)
        this.isNewInput = true
        break
      case 'MC': // Memory Clear
        this.memoryValue = 0
        break
    }
  }

  // 切换科学计算模式
  toggleScientificMode() {
    this.isScientificMode = !this.isScientificMode
  }

  // 修改后的初始化方法
  aboutToAppear() {
    this.scrollToBottom();
  }

  // 滚动到底部方法
  private scrollToBottom() {
    setTimeout(() => {
      this.scroller.scrollTo({
        xOffset: 0,
        yOffset: Number.MAX_SAFE_INTEGER, // 直接滚动到最大可能位置
        animation: false
      });
    }, 100);
  }

  build() {
    Column() {
      // 历史记录区域
      Column({ space: 5 }) {
        Scroll(this.scroller) { // 绑定 Scroller 控制器
          Column() {
            ForEach(this.history, (item: string) => {
              Text(item)
                .fontSize(16)
                .textAlign(TextAlign.End)
                .width('100%')
                .padding(5)
                .fontColor('#666666')
            })
          }
          .width('100%')
          .padding(10)
        }
        .scrollable(ScrollDirection.Vertical) // 设置滚动方向
        .width('100%')
        .height(80)      // 容器高度设置为 100（需与内容高度匹配）
        .margin({ bottom: 10 })
        .backgroundColor('#f5f5f5')
        .borderRadius(8)
      }
      .width('100%')
      .padding(20)


      // 显示区域
      Text(this.currentInput)
        .fontSize(this.currentInput.length > 15 ? 30 : 40) // 根据内容长度动态调整字体大小
        .textAlign(TextAlign.End)
        .width('100%')
        .height(80)
        .margin({ bottom: 10 })
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor('#e0f7fa')
        .borderRadius(10)
        .fontWeight(FontWeight.Bold)
        .textOverflow({ overflow: TextOverflow.Ellipsis }) // 添加文本溢出处理
        .maxLines(2) // 允许最多显示两行

      // 模式切换按钮
      Row() {
        Button('标准')
          .onClick(() => this.isScientificMode = false)
          .backgroundColor(this.isScientificMode ? '#cccccc' : '#4fc3f7')
          .width('48%')
          .height(40)
          .borderRadius(20)

        Button('科学')
          .onClick(() => this.isScientificMode = true)
          .backgroundColor(this.isScientificMode ? '#4fc3f7' : '#cccccc')
          .width('48%')
          .height(40)
          .borderRadius(20)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 15 })

      // 内存功能按钮（科学模式下显示）
      if (this.isScientificMode) {
        Row() {
          Button('MC')
            .onClick(() => this.memoryFunction('MC'))
            .backgroundColor('#f5f5f5')
            .fontColor('#000000')
            .fontSize(16)
            .width('18%')
            .height(40)
            .padding(8)
            .borderRadius(8)
          Button('MR')
            .onClick(() => this.memoryFunction('MR'))
            .backgroundColor('#f5f5f5')
            .fontColor('#000000')
            .fontSize(16)
            .width('18%')
            .height(40)
            .padding(8)
            .borderRadius(8)
          Button('MS')
            .onClick(() => this.memoryFunction('MS'))
            .backgroundColor('#f5f5f5')
            .fontColor('#000000')
            .fontSize(16)
            .width('18%')
            .height(40)
            .padding(8)
            .borderRadius(8)
          Button('M+')
            .onClick(() => this.memoryFunction('M+'))
            .backgroundColor('#f5f5f5')
            .fontColor('#000000')
            .fontSize(16)
            .width('18%')
            .height(40)
            .padding(8)
            .borderRadius(8)
          Button('M-')
            .onClick(() => this.memoryFunction('M-'))
            .backgroundColor('#f5f5f5')
            .fontColor('#000000')
            .fontSize(16)
            .width('18%')
            .height(40)
            .padding(8)
            .borderRadius(8)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 10 })
      }

      // 科学计算按钮（科学模式下显示）
      if (this.isScientificMode) {
        Grid() {
          GridItem() { Button('sin').onClick(() => this.scientificFunction('sin')).backgroundColor('#f5f5f5').fontColor('#333333').fontSize(20).padding(10).border({ width: 1, color: '#e0e0e0' }).borderRadius(8).shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 }) }
          GridItem() { Button('cos').onClick(() => this.scientificFunction('cos')).backgroundColor('#f5f5f5').fontColor('#333333').fontSize(20).padding(10).border({ width: 1, color: '#e0e0e0' }).borderRadius(8).shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 }) }
          GridItem() { Button('tan').onClick(() => this.scientificFunction('tan')).backgroundColor('#f5f5f5').fontColor('#333333').fontSize(20).padding(10).border({ width: 1, color: '#e0e0e0' }).borderRadius(8).shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 }) }
          GridItem() { Button('√').onClick(() => this.scientificFunction('sqrt')).backgroundColor('#f5f5f5').fontColor('#333333').fontSize(20).padding(10).border({ width: 1, color: '#e0e0e0' }).borderRadius(8).shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 }) }
          GridItem() { Button('log').onClick(() => this.scientificFunction('log')).backgroundColor('#f5f5f5').fontColor('#333333').fontSize(20).padding(10).border({ width: 1, color: '#e0e0e0' }).borderRadius(8).shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 }) }
          GridItem() { Button('ln').onClick(() => this.scientificFunction('ln')).backgroundColor('#f5f5f5').fontColor('#333333').fontSize(20).padding(10).border({ width: 1, color: '#e0e0e0' }).borderRadius(8).shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 }) }
          GridItem() { Button('x²').onClick(() => this.scientificFunction('square')).backgroundColor('#f5f5f5').fontColor('#333333').fontSize(20).padding(10).border({ width: 1, color: '#e0e0e0' }).borderRadius(8).shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 }) }
          GridItem() { Button('xʸ').onClick(() => this.handleOperator('pow')).backgroundColor('#f5f5f5').fontColor('#333333').fontSize(20).padding(10).border({ width: 1, color: '#e0e0e0' }).borderRadius(8).shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 }) }
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .width('100%')
        .height(100)
        .margin({ bottom: 3})
      }

      // 按钮网格
      Grid() {
        GridItem() {
          Button('AC')
            .onClick(() => this.clearAll())
            .backgroundColor('#ff5252')
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
        }
        GridItem() {
          Button('C')
            .onClick(() => this.clear())
            .backgroundColor('#ff9800')
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
        }
        GridItem() {
          Button('←')
            .onClick(() => this.backspace())
            .backgroundColor('#ff9800')
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
        }
        GridItem() {
          Button('÷')
            .onClick(() => this.handleOperator('÷'))
            .backgroundColor('#4caf50')
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
        }

        GridItem() { 
          Button('7')
            .onClick(() => this.handleNumber('7'))
            .backgroundColor('#ffffff')
            .border({ width: 1, color: '#e0e0e0' })
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
            .fontColor('#000000')
        }
        GridItem() { 
          Button('8')
            .onClick(() => this.handleNumber('8'))
            .backgroundColor('#ffffff')
            .border({ width: 1, color: '#e0e0e0' })
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
            .fontColor('#000000')
        }
        GridItem() { 
          Button('9')
            .onClick(() => this.handleNumber('9'))
            .backgroundColor('#ffffff')
            .border({ width: 1, color: '#e0e0e0' })
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
            .fontColor('#000000')
        }
        GridItem() {
          Button('×')
            .onClick(() => this.handleOperator('×'))
            .backgroundColor('#4caf50')
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
        }

        GridItem() { 
          Button('4')
            .onClick(() => this.handleNumber('4'))
            .backgroundColor('#ffffff')
            .border({ width: 1, color: '#e0e0e0' })
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
            .fontColor('#000000')
        }
        GridItem() { 
          Button('5')
            .onClick(() => this.handleNumber('5'))
            .backgroundColor('#ffffff')
            .border({ width: 1, color: '#e0e0e0' })
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
            .fontColor('#000000')
        }
        GridItem() { 
          Button('6')
            .onClick(() => this.handleNumber('6'))
            .backgroundColor('#ffffff')
            .border({ width: 1, color: '#e0e0e0' })
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
            .fontColor('#000000')
        }
        GridItem() {
          Button('-')
            .onClick(() => this.handleOperator('-'))
            .backgroundColor('#4caf50')
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
        }

        GridItem() { 
          Button('1')
            .onClick(() => this.handleNumber('1'))
            .backgroundColor('#ffffff')
            .border({ width: 1, color: '#e0e0e0' })
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
            .fontColor('#000000')
        }
        GridItem() { 
          Button('2')
            .onClick(() => this.handleNumber('2'))
            .backgroundColor('#ffffff')
            .border({ width: 1, color: '#e0e0e0' })
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
            .fontColor('#000000')
        }
        GridItem() { 
          Button('3')
            .onClick(() => this.handleNumber('3'))
            .backgroundColor('#ffffff')
            .border({ width: 1, color: '#e0e0e0' })
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
            .fontColor('#000000')
        }
        GridItem() {
          Button('+')
            .onClick(() => this.handleOperator('+'))
            .backgroundColor('#4caf50')
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
        }

        GridItem() {
          Button('0')
            .onClick(() => this.handleNumber('0'))
            .backgroundColor('#ffffff')
            .border({ width: 1, color: '#e0e0e0' })
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
            .width('100%')
            .fontColor('#000000')
        }.columnStart(0).columnEnd(1)

        GridItem() { 
          Button('.')
            .onClick(() => this.handleNumber('.'))
            .backgroundColor('#ffffff')
            .border({ width: 1, color: '#e0e0e0' })
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
            .fontColor('#000000')
        }
        GridItem() {
          Button('=')
            .onClick(() => this.calculate())
            .backgroundColor('#2196f3')
            .borderRadius(8)
            .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 })
        }
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr 1fr')
      .height('45%') // 调整高度以便显示完整
      .width('100%')
      .columnsGap(8)
      .rowsGap(8)
    }
    .width('100%')
    .height('95%') // 调整整体高度
    .padding(16)
    .backgroundColor('#f0f0f0')
  }
}