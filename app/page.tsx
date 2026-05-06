import Test from '@/components/Test'
import { Button } from '@/components/ui/button'
import React from 'react'
import { Astroid } from 'lucide-react';

export default function Home() {
  return (
    <div className='h-screen flex flex-col items-center justify-center'>
      <Test />
      <Button className='rounded-full '>
        <Astroid strokeWidth={1.75} /> 
        Click Me </Button>

        
    </div>
  )
}
