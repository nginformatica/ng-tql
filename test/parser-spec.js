const expect = require('chai').expect;
const tql = require('../dist/tql');

describe('Parser specification', () => {
    describe('Inferred type declarations', () => {

        it('Shouldn\'t support free-type variables', () => {
            expect(() => tql.parse('Declare Age')).to.throw(TypeError, /Cannot infer type of free variable/);
        });

        it('Should infer any number to integer', () => {
            const ast = tql.parse('Declare Age := 18');
            expect(ast[0].type[0]).to.be.equal('int');
        });

        it('Should infer symbols', () => {

        });

        it('Should infer any char(*) to varchar', () => {

        });

        it('Should infer booleans', () => {

        });

    });
});
